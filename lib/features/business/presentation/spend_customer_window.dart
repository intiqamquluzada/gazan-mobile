import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
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
    setState(() => _closing = true);
    try {
      await ref.read(panelRepositoryProvider).closeSession(_session.id);
    } on ApiException {
      // An expired session has nothing left to close.
    }
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final S s = ref.watch(sProvider);
    final AppPalette p = context.palette;
    final SpendSession c = _session;
    return Padding(
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
                            onPressed:
                                _busyId == null ? () => _use(r) : null,
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
    );
  }
}
