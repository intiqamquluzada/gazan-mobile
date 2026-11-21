import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pill_tab_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/i18n/strings.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../../wallet/application/wallet_providers.dart';
import '../../wallet/domain/coin_summary.dart';
import '../../wallet/presentation/my_rewards_screen.dart';
import '../application/loyalty_providers.dart';
import '../domain/loyalty_card.dart';
import '../domain/loyalty_program.dart';
import 'widgets/loyalty_card_widget.dart';
import '../../../core/widgets/celebrations.dart';

/// The customer's "Kartlarım" hub. Two tabs:
/// • Kartlarım — coin balances + loyalty cards
/// • Hədiyyələrim — the voucher wallet (moved here from its own nav tab)
class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.myCards),
          actions: <Widget>[
            IconButton(
              icon: const Icon(AppIcons.refresh),
              onPressed: () {
                ref.invalidate(myCardsProvider);
                ref.invalidate(coinSummaryProvider);
              },
            ),
          ],
          bottom: PillTabBar(tabs: <String>[s.myCards, s.tabRewards]),
        ),
        body: const TabBarView(
          children: <Widget>[
            _CardsTab(),
            MyRewardsBody(),
          ],
        ),
      ),
    );
  }
}

/// Coin balances + loyalty cards — the first tab of [MyCardsScreen].
class _CardsTab extends ConsumerWidget {
  const _CardsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<List<LoyaltyCard>> cards = ref.watch(myCardsProvider);
    final AsyncValue<CoinSummary> coins = ref.watch(coinSummaryProvider);

    // A card whose ready-reward count grew since we last celebrated it
    // gets the reward sheet — once per new reward.
    ref.listen<AsyncValue<List<LoyaltyCard>>>(myCardsProvider,
        (AsyncValue<List<LoyaltyCard>>? _, AsyncValue<List<LoyaltyCard>> next) {
      final List<LoyaltyCard>? list = next.valueOrNull;
      if (list == null) return;
      () async {
        for (final LoyaltyCard c in list) {
          if (await RewardCelebrationLedger.shouldCelebrate(
                  c.id, c.rewardsAvailable) &&
              context.mounted) {
            await showRewardReadySheet(
              context,
              title: s.rewardReadyTitle,
              message: s.rewardReadyBody,
              actionLabel: s.useReward,
              onAction: () => context.push('/rewards'),
            );
            break; // one celebration at a time
          }
        }
      }();
    });

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myCardsProvider);
        ref.invalidate(coinSummaryProvider);
        ref.invalidate(programByIdProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.huge,
        ),
        children: <Widget>[
          _CoinBalanceCard(coinsAsync: coins),
          const SizedBox(height: AppSpacing.xl),
          Text(s.loyaltyCards,
              style: AppTextStyles.h2.copyWith(
                  color: context.palette.ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.md),
          cards.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object e, _) => EmptyState(
              title: s.error,
              subtitle: e.toString(),
              icon: AppIcons.error,
            ),
            data: (List<LoyaltyCard> list) {
              if (list.isEmpty) {
                return EmptyState(
                  title: s.noCardsYet,
                  subtitle: s.discoverCardHint,
                  icon: AppIcons.gift,
                  action: PrimaryButton(
                    label: s.tabHome,
                    icon: AppIcons.home,
                    expanded: false,
                    onPressed: () => context.go('/home'),
                  ),
                );
              }
              return Column(
                children: <Widget>[
                  for (final LoyaltyCard c in list) ...<Widget>[
                    _CardEntry(card: c),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Coin balance hero + per-business breakdown — relocated here from the
/// old Cüzdan tab. Tapping a row jumps to that business's page where
/// "Coinlə al" lives.
class _CoinBalanceCard extends ConsumerWidget {
  const _CoinBalanceCard({required this.coinsAsync});

  final AsyncValue<CoinSummary> coinsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S str = ref.watch(sProvider);
    final AppPalette p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: coinsAsync.when(
        loading: () => SizedBox(
          height: 80,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  p.caramel),
            ),
          ),
        ),
        error: (Object e, _) => Text(
          str.coinBalanceNotLoaded,
          style: AppTextStyles.bodySm.copyWith(color: p.textSecondary),
        ),
        // Coins only count where they were earned, so the venues are the
        // headline; the grand total is just a footnote.
        data: (CoinSummary s) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(AppIcons.token, color: p.caramel, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(str.coinsByVenue,
                      style: AppTextStyles.h3.copyWith(
                          color: context.palette.ink, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (s.companies.isEmpty)
              Text(str.noCoinsYet,
                  style: AppTextStyles.body.copyWith(color: p.textSecondary))
            else
              for (int i = 0; i < s.companies.length; i++) ...<Widget>[
                if (i > 0) Divider(height: 1, color: p.divider),
                _VenueBalanceRow(balance: s.companies[i]),
              ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline_rounded,
                    size: 16, color: p.caramel),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '${str.coinsOnlyHere} ${str.coinsTotalAcross(s.total)}',
                    style: AppTextStyles.caption
                        .copyWith(color: p.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One venue's coins; tapping opens that venue, where they can be spent.
class _VenueBalanceRow extends ConsumerWidget {
  const _VenueBalanceRow({required this.balance});

  final CompanyBalance balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final String? id = balance.companyId;
    return InkWell(
      onTap: id == null ? null : () => context.push('/companies/$id'),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(balance.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body
                      .copyWith(color: context.palette.textPrimary)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('${balance.balance}',
                style: AppTextStyles.h3.copyWith(
                    color: context.palette.caramelText,
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: 4),
            Text(s.coinUnit,
                style: AppTextStyles.caption
                    .copyWith(color: context.palette.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CardEntry extends ConsumerWidget {
  const _CardEntry({required this.card});

  final LoyaltyCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<Company?> companyAsync =
        ref.watch(companyByIdProvider(card.companyId));

    return companyAsync.when(
      loading: () => const _CardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (Company? company) {
        if (company == null) return const SizedBox.shrink();
        final AsyncValue<LoyaltyProgram?> programAsync =
            ref.watch(programByIdProvider(card.programId));
        if (programAsync.isLoading && !programAsync.hasValue) {
          return const _CardSkeleton();
        }
        final LoyaltyProgram? program = programAsync.valueOrNull;
        if (program == null) {
          return _CardLoadError(
            message: s.cardNotLoaded,
            retryLabel: s.retry,
            onRetry: () =>
                ref.invalidate(programByIdProvider(card.programId)),
          );
        }
        return Builder(
          builder: (BuildContext _) {
            return Column(
              children: <Widget>[
                LoyaltyCardWidget(
                  company: company,
                  program: program,
                  card: card,
                  onTap: () => context.push('/companies/${company.id}'),
                ),
                if (card.rewardsAvailable > 0) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.palette.rewardSoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(AppIcons.gift, color: AppColors.reward),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${card.rewardsAvailable} ${s.rewardsWaitSuffix}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onReward,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/nfc'),
                          child: Text(s.nfcTapShort),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _CardLoadError extends StatelessWidget {
  const _CardLoadError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline_rounded, color: p.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: p.textSecondary),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    );
  }
}
