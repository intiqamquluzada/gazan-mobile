import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/i18n/strings_panel2.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';

class AdminCoinsScreen extends ConsumerStatefulWidget {
  const AdminCoinsScreen({super.key});

  @override
  ConsumerState<AdminCoinsScreen> createState() => _AdminCoinsScreenState();
}

class _AdminCoinsScreenState extends ConsumerState<AdminCoinsScreen> {
  bool _loading = true;
  String? _error;
  final List<AdminCoinTxn> _txns = <AdminCoinTxn>[];
  int _page = 0;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 0;
      });
    }
    try {
      final AdminPage<AdminCoinTxn> p =
          await ref.read(adminRepositoryProvider).coinTransactions(page: _page);
      setState(() {
        if (reset) _txns.clear();
        _txns.addAll(p.content);
        _totalPages = p.totalPages;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_page + 1 >= _totalPages) return;
    setState(() => _page++);
    await _load();
  }

  Future<void> _refreshAll() async {
    ref
      ..invalidate(adminCoinSummaryProvider)
      ..invalidate(adminCoinsByCompanyProvider);
    await _load(reset: true);
  }

  Future<void> _openAdjust() async {
    final bool? done = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AdjustSheet(ref: ref),
      ),
    );
    if (done == true) await _refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AsyncValue<CoinSummary?> summaryAsync =
        ref.watch(adminCoinSummaryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdjust,
        icon: const Icon(AppIcons.add),
        label: Text(s.coinAdjustment),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.huge),
            children: <Widget>[
              Text(s.coinControl, style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.lg),
              summaryAsync.when(
                loading: () => const _SummarySkeleton(),
                error: (Object e, _) => const SizedBox.shrink(),
                data: (CoinSummary? sum) => sum == null
                    ? const SizedBox.shrink()
                    : _SummaryCard(s: sum),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.coinsByCompanyTitle, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              ref.watch(adminCoinsByCompanyProvider).when(
                    loading: () => const SizedBox.shrink(),
                    error: (Object e, _) =>
                        Text('$e', style: AppTextStyles.bodySm),
                    data: (List<CompanyCoinRow> rows) => rows.isEmpty
                        ? Text(s.noTransactions, style: AppTextStyles.bodySm)
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: <DataColumn>[
                                DataColumn(label: Text(s.businessLabel)),
                                DataColumn(
                                    label: Text(s.earnedLabel), numeric: true),
                                DataColumn(
                                    label: Text(s.spentLabel), numeric: true),
                                DataColumn(
                                    label: Text(s.grantsLabel), numeric: true),
                              ],
                              rows: <DataRow>[
                                for (final CompanyCoinRow r in rows)
                                  DataRow(cells: <DataCell>[
                                    DataCell(Text(r.name)),
                                    DataCell(Text('${r.earned}')),
                                    DataCell(Text('${r.spent}')),
                                    DataCell(Text('${r.grants}')),
                                  ]),
                              ],
                            ),
                          ),
                  ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.recentTransactions, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              if (_loading && _txns.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null && _txns.isEmpty)
                EmptyState(
                    title: s.notLoaded, subtitle: _error, icon: AppIcons.error)
              else if (_txns.isEmpty)
                EmptyState(
                  title: s.noTransactions,
                  subtitle: s.transactionsWillShow,
                  icon: AppIcons.token,
                )
              else ...<Widget>[
                for (final AdminCoinTxn t in _txns) _TxnTile(t: t),
                if (_page + 1 < _totalPages)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: _loading ? null : _loadMore,
                        child: Text(_loading ? s.loading : s.loadMore),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.s});

  final CoinSummary s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S str = ref.watch(sProvider);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: kHeroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.brand(AppColors.action),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(str.inCirculation,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.onDark.withValues(alpha: 0.85))),
          Text('${s.circulating} coin',
              style: AppTextStyles.display.copyWith(color: AppColors.onDark)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              _Metric(label: str.earnedLabel, value: '${s.earned}'),
              const SizedBox(width: AppSpacing.xl),
              _Metric(label: str.spentLabel, value: '${s.spent}'),
              const SizedBox(width: AppSpacing.xl),
              _Metric(label: str.transactionWord, value: '${s.transactions}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(value, style: AppTextStyles.h3.copyWith(color: AppColors.onDark)),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.onDark.withValues(alpha: 0.8))),
      ],
    );
  }
}

class _TxnTile extends ConsumerWidget {
  const _TxnTile({required this.t});

  final AdminCoinTxn t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S str = ref.watch(sProvider);
    final bool earn = t.amount >= 0;
    final Color c = earn ? AppColors.success : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                earn ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: c,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(t.userName ?? t.userEmail ?? str.unknownParen,
                      style: AppTextStyles.bodyLg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    <String?>[t.companyName, t.note]
                        .where((String? s) => s != null && s.isNotEmpty)
                        .join(' · '),
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${earn ? '+' : ''}${t.amount}',
              style: AppTextStyles.bodyLg.copyWith(
                color: c,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    );
  }
}

/// Pick a user (by email/name) then apply a signed coin adjustment.
class _AdjustSheet extends StatefulWidget {
  const _AdjustSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AdjustSheet> createState() => _AdjustSheetState();
}

class _AdjustSheetState extends State<_AdjustSheet> {
  final TextEditingController _userSearch = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  List<AdminUser> _results = <AdminUser>[];
  AdminUser? _picked;
  String? _companyId;
  bool _searching = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _userSearch.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _searching = true);
    try {
      final AdminPage<AdminUser> p = await widget.ref
          .read(adminRepositoryProvider)
          .users(q: _userSearch.text.trim(), size: 8);
      setState(() {
        _results = p.content;
        _searching = false;
      });
    } catch (e) {
      setState(() {
        _searching = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _submit() async {
    final int? amount = int.tryParse(_amount.text.trim());
    if (_picked == null || amount == null || amount == 0) {
      setState(() => _error = widget.ref.read(sProvider).pickUserAndAmount);
      return;
    }
    // Coins only exist per venue, so the adjustment must name one.
    if (_companyId == null) {
      setState(() => _error = widget.ref.read(sProvider).pVenueRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.ref.read(adminRepositoryProvider).adjustCoins(
            userId: _picked!.id,
            companyId: _companyId,
            amount: amount,
            note: _note.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = widget.ref.watch(sProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.coinAdjustment, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(s.adjustPositiveNegative, style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.lg),
            if (_picked == null) ...<Widget>[
              TextField(
                controller: _userSearch,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: s.searchUserByEmail,
                  prefixIcon: const Icon(AppIcons.search),
                  suffixIcon: IconButton(
                    icon: _searching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(AppIcons.search),
                    onPressed: _searching ? null : _search,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    for (final AdminUser u in _results)
                      ListTile(
                        dense: true,
                        title: Text(u.fullName.isEmpty ? u.email : u.fullName),
                        subtitle: Text(u.email),
                        onTap: () => setState(() => _picked = u),
                      ),
                  ],
                ),
              ),
            ] else ...<Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.caramelSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              _picked!.fullName.isEmpty
                                  ? _picked!.email
                                  : _picked!.fullName,
                              style: AppTextStyles.bodyLg),
                          Text(_picked!.email, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _picked = null),
                      child: Text(s.change),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, _) {
                  final AsyncValue<List<AdminCompany>> companiesAsync =
                      ref.watch(adminCompanyOptionsProvider);
                  final List<AdminCompany> companies =
                      companiesAsync.valueOrNull ?? const <AdminCompany>[];
                  return DropdownButtonFormField<String>(
                    initialValue:
                        companies.any((AdminCompany c) => c.id == _companyId)
                            ? _companyId
                            : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: s.pVenue,
                      helperText: companiesAsync.hasError
                          ? s.networkError
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    items: <DropdownMenuItem<String>>[
                      for (final AdminCompany c in companies)
                        DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (String? v) => setState(() {
                      _companyId = v;
                      _error = null;
                    }),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _amount,
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                decoration: InputDecoration(
                  labelText: s.amountExample,
                  prefixIcon: const Icon(AppIcons.token),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _note,
                decoration: InputDecoration(
                  labelText: s.noteOptional,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? s.applyingWord : s.applyAction),
                ),
              ),
            ],
            if (_error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.dangerText)),
            ],
          ],
        ),
      ),
    );
  }
}
