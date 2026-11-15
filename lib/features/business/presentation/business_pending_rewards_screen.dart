import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user_role.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../../loyalty/application/loyalty_providers.dart';
import '../application/business_providers.dart';
import '../application/panel_providers.dart';
import '../domain/panel_models.dart';
import 'spend_customer_window.dart';

/// One reward waiting at the counter.
class PendingReward {
  const PendingReward({
    required this.kind,
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    this.customerPhone,
    this.coinCost = 0,
    this.createdAt,
  });

  final String kind; // COIN | CARD
  final String id;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String title;
  final int coinCost;
  final DateTime? createdAt;

  bool get isCoin => kind == 'COIN';

  factory PendingReward.fromJson(Map<String, dynamic> j) => PendingReward(
        kind: (j['kind'] as String?) ?? 'COIN',
        id: j['id'] as String,
        customerId: (j['customerId'] as String?) ?? '',
        customerName: (j['customerName'] as String?) ?? '—',
        customerPhone: j['customerPhone'] as String?,
        title: (j['title'] as String?) ?? '',
        coinCost: (j['coinCost'] as num?)?.toInt() ?? 0,
        createdAt: j['createdAt'] == null
            ? null
            : DateTime.tryParse(j['createdAt'] as String)?.toLocal(),
      );
}

final AutoDisposeFutureProvider<List<PendingReward>> pendingRewardsProvider =
    FutureProvider.autoDispose<List<PendingReward>>((Ref ref) async {
  final List<dynamic> raw = await ref
      .read(apiClientProvider)
      .get<List<dynamic>>('/api/v1/business/rewards/pending');
  return raw
      .cast<Map<String, dynamic>>()
      .map(PendingReward.fromJson)
      .toList(growable: false);
});

/// The cashier's main screen. When a customer taps the "spend" card their
/// window opens here by itself; below it, everything waiting to be handed
/// over, searchable by name.
class BusinessPendingRewardsScreen extends ConsumerStatefulWidget {
  const BusinessPendingRewardsScreen({super.key});

  @override
  ConsumerState<BusinessPendingRewardsScreen> createState() =>
      _PendingRewardsState();
}

class _PendingRewardsState extends ConsumerState<BusinessPendingRewardsScreen>
    with WidgetsBindingObserver {
  static const Duration _pollEvery = Duration(seconds: 3);
  static const String _location = '/business/scan';

  String _query = '';
  String? _busyId;
  Timer? _timer;
  List<SpendSession> _sessions = const <SpendSession>[];
  final Set<String> _opened = <String>{};
  bool _windowOpen = false;
  bool _polling = false;
  bool _pollFailed = false;
  bool _appActive = true;
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_poll());
    _timer = Timer.periodic(_pollEvery, (_) => unawaited(_poll()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
  }

  bool get _visible {
    // The desktop till usually sits minimised or behind other windows and
    // must still open a customer's window (CounterWatcher raises it).
    final bool desktop = !kIsWeb && Platform.isWindows;
    if ((!_appActive && !desktop) || !mounted) return false;
    final GoRouter router = GoRouter.of(context);
    return router.routeInformationProvider.value.uri.path == _location;
  }

  Future<void> _poll() async {
    if (_polling || !_visible) return;
    // Every ~30 s also reload the waiting gifts: customers buy and unlock
    // them while the till is open.
    if (++_ticks % 10 == 0) ref.invalidate(pendingRewardsProvider);
    _polling = true;
    try {
      final List<SpendSession> open =
          await ref.read(panelRepositoryProvider).openSpendSessions();
      if (!mounted) return;
      final bool hasNew = open.any((SpendSession x) => !_opened.contains(x.id));
      setState(() {
        _sessions = open;
        _pollFailed = false;
      });
      if (hasNew) ref.invalidate(pendingRewardsProvider);
      _openNext();
    } catch (_) {
      // Any failure (offline, timeout, bad payload) shows the banner; the
      // next tick tries again.
      if (mounted) setState(() => _pollFailed = true);
    } finally {
      _polling = false;
    }
  }

  /// Opens the oldest customer not yet shown, one window at a time.
  void _openNext() {
    if (_windowOpen || !mounted) return;
    for (final SpendSession x in _sessions.reversed) {
      if (!_opened.contains(x.id)) {
        unawaited(_open(x));
        return;
      }
    }
  }

  Future<void> _open(SpendSession x) async {
    _opened.add(x.id);
    _windowOpen = true;
    await showSpendCustomerWindow(context, x);
    _windowOpen = false;
    if (!mounted) return;
    ref
      ..invalidate(pendingRewardsProvider)
      ..invalidate(myBusinessStatsProvider)
      ..invalidate(myCustomersProvider);
    unawaited(_poll());
  }

  Future<void> _hand(PendingReward r) async {
    final S s = ref.read(sProvider);
    final bool ok = await showConfirmSheet(
      context,
      title: s.rewardHandOverTitle,
      body: '${r.customerName} · ${r.title}',
      confirmLabel: s.rewardHandOver,
      cancelLabel: s.cancel,
      icon: Icons.card_giftcard_rounded,
      danger: AppColors.success,
    );
    if (!ok || !mounted) return;
    setState(() => _busyId = r.id);
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await container.read(apiClientProvider).post<dynamic>(
        '/api/v1/business/rewards/use',
        body: <String, dynamic>{
          'kind': r.kind,
          'id': r.id,
          'customerId': r.customerId,
        },
      );
      container
        ..invalidate(pendingRewardsProvider)
        ..invalidate(myCardsProvider)
        ..invalidate(myBusinessStatsProvider)
        ..invalidate(myCustomersProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('${r.title} · ${s.usedSuffixCheck}')),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<PendingReward>> async =
        ref.watch(pendingRewardsProvider);
    final bool cashier = ref.watch(currentUserProvider)?.role == UserRole.cashier;

    // An owner who has not set up the venue yet has no till: point them at
    // creating it rather than showing a misleading network error.
    final AsyncValue<Company?> companyAsync =
        cashier ? const AsyncData<Company?>(null) : ref.watch(myCompanyProvider);
    if (!cashier && companyAsync.hasValue && companyAsync.value == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.cashierWindow)),
        body: EmptyState(
          title: s.createYourBusiness,
          subtitle: s.createBusinessHint,
          icon: Icons.storefront_rounded,
          action: FilledButton(
            onPressed: () => context.go('/business/profile'),
            child: Text(s.createBusiness),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.cashierWindow),
        actions: <Widget>[
          if (cashier)
            IconButton(
              tooltip: s.account,
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () => context.push('/business/account'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingRewardsProvider);
          await _poll();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md,
              AppSpacing.xl, AppSpacing.huge),
          children: <Widget>[
            if (_pollFailed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(s.networkError,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.dangerText)),
              ),
            _sessionsSection(s),
            TextField(
              onChanged: (String v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: s.search,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object e, _) =>
                  EmptyState(title: s.notLoaded, subtitle: '$e'),
              data: (List<PendingReward> all) => _pendingList(s, all),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionsSection(S s) {
    if (_sessions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(s.cashierAtTill, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        for (final SpendSession x in _sessions)
          Card(
            child: ListTile(
              leading: const Icon(Icons.point_of_sale_rounded,
                  color: AppColors.caramel),
              title: Text(x.customerName),
              subtitle: Text('${x.rewards.length} ${s.rewardWord}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _windowOpen ? null : () => _open(x),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _pendingList(S s, List<PendingReward> all) {
    final String q = _query.toLowerCase();
    final List<PendingReward> list = q.isEmpty
        ? all
        : all
            .where((PendingReward r) =>
                r.customerName.toLowerCase().contains(q))
            .toList();
    if (list.isEmpty) {
      return EmptyState(
        title: s.noPendingRewards,
        subtitle: s.noPendingRewardsHint,
        icon: Icons.card_giftcard_rounded,
      );
    }
    final AppPalette p = context.palette;
    return Column(
      children: <Widget>[
        for (final PendingReward r in list)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.rewardSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.card_giftcard_rounded,
                      color: AppColors.onReward),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(r.customerName,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        r.isCoin
                            ? '${r.title} · ${r.coinCost} ${s.coinLabel}'
                            : r.title,
                        style: AppTextStyles.bodySm
                            .copyWith(color: p.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (_busyId == r.id)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                    onPressed: () => _hand(r),
                    child: Text(s.rewardHandOver),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
