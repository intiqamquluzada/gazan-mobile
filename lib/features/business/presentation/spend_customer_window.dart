import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/i18n/strings_panel2.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/avatar.dart';
import '../application/panel_providers.dart';
import '../domain/panel_models.dart';

/// The customer's window at the till: who they are, what they have, and a
/// button per reward for the cashier to mark it used.
Future<void> showSpendCustomerWindow(
  BuildContext context,
  SpendSession session,
) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: _CustomerWindow(session: session),
      ),
    ),
  );
}

class _CustomerWindow extends ConsumerStatefulWidget {
  const _CustomerWindow({required this.session});

  final SpendSession session;

  @override
  ConsumerState<_CustomerWindow> createState() => _CustomerWindowState();
}

class _CustomerWindowState extends ConsumerState<_CustomerWindow> {
  late SpendSession _session = widget.session;
  String? _busyId;
  bool _closing = false;
  String? _error;
  final List<String> _used = <String>[];

  /// Re-reads the open sessions so the window follows what happens elsewhere
  /// (another till served the customer, or the session timed out).
  Timer? _poll;
  bool _polling = false;

  /// Set once the session left the open list; the window closes shortly after.
  bool _gone = false;
  bool _popped = false;

  /// Pops the window exactly once, whichever path gets here first.
  void _dismiss() {
    if (_popped || !mounted) return;
    _popped = true;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_polling || _closing || _gone || _busyId != null) return;
    _polling = true;
    try {
      final List<SpendSession> open =
          await ref.read(panelRepositoryProvider).openSpendSessions();
      if (!mounted || _closing || _gone || _busyId != null) return;
      final SpendSession? fresh = open
          .where((SpendSession x) => x.id == _session.id)
          .firstOrNull;
      if (fresh != null) {
        setState(() => _session = fresh);
        return;
      }
      _poll?.cancel();
      setState(() => _gone = true);
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      _dismiss();
    } catch (_) {
      // A missed poll is harmless; the next tick tries again.
    } finally {
      _polling = false;
    }
  }

  Future<void> _use(SpendReward r) async {
    setState(() {
      _busyId = r.id;
      _error = null;
    });
    try {
      final SpendSession updated = await ref
          .read(panelRepositoryProvider)
          .useReward(_session.id, kind: r.kind, rewardId: r.id);
      if (!mounted) return;
      setState(() {
        _session = updated;
        _used.add(r.title);
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    _poll?.cancel();
    if (_gone) {
      _dismiss();
      return;
    }
    setState(() => _closing = true);
    try {
      await ref.read(panelRepositoryProvider).closeSession(_session.id);
    } catch (_) {
      // An expired session has nothing left to close; a network failure
      // must not trap the cashier in the window either.
    }
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    final SpendSession c = _session;
    // Android back goes through the same path as the Close button, so the
    // session is closed on the server rather than left hanging.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) _close();
      },
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Avatar(name: c.customerName, imageUrl: c.avatarUrl, size: 56),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.customerName, style: AppTextStyles.h2),
                    if (c.customerPhone != null)
                      Text(c.customerPhone!,
                          style: AppTextStyles.bodySm
                              .copyWith(color: p.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('${c.coinBalance}', style: AppTextStyles.h2),
                  Text(s.coinLabel, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                if (c.cards.isNotEmpty) ...<Widget>[
                  Text(s.cashierCards, style: AppTextStyles.overline),
                  const SizedBox(height: AppSpacing.sm),
                  for (final SpendCard card in c.cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(card.programTitle,
                                style: AppTextStyles.body),
                          ),
                          Text('${card.stamps}/${card.stampsRequired}',
                              style: AppTextStyles.bodySm.copyWith(
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Text(s.cashierRewards, style: AppTextStyles.overline),
                const SizedBox(height: AppSpacing.sm),
                if (c.rewards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(s.cashierNoRewardsLeft,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body),
                  ),
                for (final SpendReward r in c.rewards)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: p.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.card_giftcard_rounded,
                            color: AppColors.caramel),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            r.kind == 'COIN' && r.coinCost > 0
                                ? '${r.title} · ${r.coinCost} ${s.coinLabel}'
                                : r.title,
                            style: AppTextStyles.body,
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
                            onPressed: _busyId == null && !_gone
                                ? () => _use(r)
                                : null,
                            child: Text(s.markUsed),
                          ),
                      ],
                    ),
                  ),
                for (final String t in _used)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: AppColors.success),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(t, style: AppTextStyles.bodySm),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_gone) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(s.pSpendSessionGone,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
          if (_error != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.dangerText)),
          ],
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: _closing ? null : _close,
            child: Text(s.close),
          ),
        ],
      ),
      ),
    );
  }
}
