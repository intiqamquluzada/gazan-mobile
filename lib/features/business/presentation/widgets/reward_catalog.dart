import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../wallet/application/wallet_providers.dart';
import '../../../wallet/domain/coin_reward.dart';

/// Owner-managed coin-reward catalog: "100 coin → San Sebastian".
/// Lives in the Programlar (loyalty programs) section so the owner
/// manages all customer incentives — stamp programs + coin rewards —
/// in one place.
class RewardCatalog extends ConsumerWidget {
  const RewardCatalog({super.key, required this.companyId});

  final String companyId;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final S s = ref.read(sProvider);
    final TextEditingController title = TextEditingController();
    final TextEditingController desc = TextEditingController();
    final TextEditingController cost = TextEditingController();
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(s.addReward),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: title,
                decoration: InputDecoration(hintText: s.rewardNameHint),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: desc,
                decoration: InputDecoration(hintText: s.descOptionalHint),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: cost,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: s.howManyCoinHint,
                  prefixIcon: const Icon(AppIcons.token),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.add),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final int? c = int.tryParse(cost.text.trim());
    if (title.text.trim().isEmpty || c == null || c <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.nameAndValidCoin)),
        );
      }
      return;
    }
    try {
      await ref.read(walletRepositoryProvider).createReward(
            companyId: companyId,
            title: title.text.trim(),
            description: desc.text.trim().isEmpty ? null : desc.text.trim(),
            coinCost: c,
          );
      ref.invalidate(coinRewardsProvider(companyId));
    } on ApiException catch (e) {
      _toast(context, e.message);
    }
  }

  void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, CoinReward r) async {
    final S s = ref.read(sProvider);
    final TextEditingController title = TextEditingController(text: r.title);
    final TextEditingController desc =
        TextEditingController(text: r.description ?? '');
    final TextEditingController cost =
        TextEditingController(text: '${r.coinCost}');
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(s.giftEditTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: title,
                decoration: InputDecoration(hintText: s.rewardNameHint),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: desc,
                decoration: InputDecoration(hintText: s.descOptionalHint),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: cost,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: s.howManyCoinHint,
                  prefixIcon: const Icon(AppIcons.token),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.saveShort),
          ),
        ],
      ),
    );
    final String t = title.text.trim();
    final String d = desc.text.trim();
    final int? c = int.tryParse(cost.text.trim());
    if (ok != true || !context.mounted) return;
    if (t.isEmpty || c == null || c <= 0) {
      _toast(context, s.nameAndValidCoin);
      return;
    }
    try {
      await ref
          .read(walletRepositoryProvider)
          .updateReward(r.id, title: t, description: d, coinCost: c);
      ref.invalidate(coinRewardsProvider(companyId));
    } on ApiException catch (e) {
      if (context.mounted) _toast(context, e.message);
    }
  }

  Future<void> _setActive(
      BuildContext context, WidgetRef ref, CoinReward r, bool active) async {
    try {
      await ref.read(walletRepositoryProvider).updateReward(r.id, active: active);
      ref.invalidate(coinRewardsProvider(companyId));
    } on ApiException catch (e) {
      if (context.mounted) _toast(context, e.message);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, CoinReward r) async {
    final S s = ref.read(sProvider);
    final bool ok = await showConfirmSheet(
      context,
      title: s.giftDeleteTitle,
      body: '${r.title}\n${s.giftDeleteBody}',
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(walletRepositoryProvider).deleteReward(r.id);
      ref.invalidate(coinRewardsProvider(companyId));
    } on ApiException catch (e) {
      if (context.mounted) _toast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<CoinReward>> async =
        ref.watch(coinRewardsProvider(companyId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(s.rewardCatalog, style: AppTextStyles.h3)),
            TextButton.icon(
              onPressed: () => _add(context, ref),
              icon: const Icon(AppIcons.add, size: 18),
              label: Text(s.add),
            ),
          ],
        ),
        Text(
          s.coinGiftsSub,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object e, _) =>
              Text('${s.error}: $e', style: AppTextStyles.bodySm),
          data: (List<CoinReward> list) {
            if (list.isEmpty) {
              return Text(
                s.noRewardsYetHint,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            }
            return Column(
              children: <Widget>[
                for (final CoinReward r in list)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.caramelSoft,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(AppIcons.token,
                                  size: 14, color: AppColors.action),
                              const SizedBox(width: 4),
                              Text('${r.coinCost}',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.action,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(r.title,
                                  style: AppTextStyles.bodyLg.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: r.active
                                        ? null
                                        : AppColors.textTertiary,
                                  )),
                              Text(r.active ? s.giftActive : s.giftInactive,
                                  style: AppTextStyles.caption),
                              if ((r.description ?? '').isNotEmpty)
                                Text(r.description!,
                                    style: AppTextStyles.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Switch(
                          value: r.active,
                          onChanged: (bool v) => _setActive(context, ref, r, v),
                        ),
                        IconButton(
                          tooltip: s.edit,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _edit(context, ref, r),
                        ),
                        IconButton(
                          tooltip: s.delete,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.danger),
                          onPressed: () => _delete(context, ref, r),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
