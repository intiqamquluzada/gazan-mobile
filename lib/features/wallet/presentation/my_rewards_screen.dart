import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/pill_tab_bar.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/company_logo.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../rewards/application/rewards_providers.dart';
import '../../rewards/domain/reward_claim.dart';

/// "Hədiyyələrim" — the customer's voucher wallet. Two tabs:
/// • Aktiv — coins-purchased + completed-stamp-card vouchers ready to use
/// • İstifadə olunmuş — historical claims confirmed at the cashier
///
/// Coin balances live on the Kartlarım screen now.
class MyRewardsScreen extends ConsumerWidget {
  const MyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.tabRewards)),
      body: const MyRewardsBody(),
    );
  }
}

/// The "Hədiyyələrim" content (Aktiv / İstifadə olunmuş sub-tabs) with no
/// Scaffold or AppBar — so it can be embedded as a sub-tab inside the
/// Kartlarım screen as well as shown standalone.
class MyRewardsBody extends ConsumerWidget {
  const MyRewardsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          PillTabBar(tabs: <String>[s.rewardsActiveTab, s.rewardsUsedTab]),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _RewardsList(
                  provider: myActiveRewardsProvider,
                  emptyTitle: s.noActiveRewards,
                  emptySubtitle: s.noActiveRewardsSub,
                  activeMode: true,
                ),
                _RewardsList(
                  provider: myUsedRewardsProvider,
                  emptyTitle: s.noUsageHistory,
                  emptySubtitle: s.noUsageHistorySub,
                  activeMode: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardsList extends ConsumerWidget {
  const _RewardsList({
    required this.provider,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.activeMode,
  });

  final FutureProvider<List<AppRewardClaim>> provider;
  final String emptyTitle;
  final String emptySubtitle;
  final bool activeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AppRewardClaim>> async = ref.watch(provider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myActiveRewardsProvider);
        ref.invalidate(myUsedRewardsProvider);
      },
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // Scrollable so pull-to-refresh works on these states too.
        error: (Object e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            const SizedBox(height: 24),
            ErrorState(error: e, onRetry: () => ref.invalidate(provider)),
          ],
        ),
        data: (List<AppRewardClaim> list) {
          if (list.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                const SizedBox(height: 24),
                EmptyState(
                  title: emptyTitle,
                  subtitle: emptySubtitle,
                  icon: AppIcons.gift,
                  image: 'assets/illustrations/onb_gift.png',
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.huge),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (BuildContext _, int i) => _RewardTile(
              claim: list[i],
              activeMode: activeMode,
            ),
          );
        },
      ),
    );
  }
}

class _RewardTile extends ConsumerWidget {
  const _RewardTile({required this.claim, required this.activeMode});

  final AppRewardClaim claim;
  final bool activeMode;

  String _ago(S s, DateTime? d) {
    if (d == null) return '';
    final Duration diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return s.nowWord;
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${s.minAgo}';
    if (diff.inHours < 24) return '${diff.inHours} ${s.hourAgo}';
    return '${diff.inDays} ${s.dayAgo}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: () => context.push('/companies/${claim.companyId}'),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: dark ? AppColorsDark.border : AppColors.border,
            ),
            boxShadow: dark ? null : AppShadows.sm,
          ),
          child: Row(
            children: <Widget>[
              CompanyLogo(
                name: claim.companyName,
                brandColor: AppColors.action,
                imageUrl: claim.companyLogoUrl,
                size: 52,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(claim.title,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(claim.companyName,
                        style: AppTextStyles.bodySm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: claim.isCoin
                                ? AppColors.caramelSoft
                                : AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            claim.isCoin ? s.coinLabel : s.stampLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: claim.isCoin
                                  ? AppColors.action
                                  : AppColors.successText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          activeMode
                              ? s.showQrCashier
                              : '${s.usedPrefix} · ${_ago(s, claim.usedAt)}',
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (claim.isCoin && claim.coinCost > 0) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(AppIcons.token,
                            size: 14, color: AppColors.action),
                        const SizedBox(width: 2),
                        Text('${claim.coinCost}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.action,
                              fontWeight: FontWeight.w800,
                            )),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
