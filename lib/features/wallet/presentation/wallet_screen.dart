import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/company_logo.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/wallet_providers.dart';
import '../domain/coin_reward.dart';
import '../domain/coin_summary.dart';

/// Coin wallet — real data from `GET /api/v1/coins/me`. Shows the total
/// balance, the per-business breakdown and the live reward catalog
/// (`GET /api/v1/coin-rewards`) with affordability per business.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const List<int> _palette = <int>[
    0xFF6C2BD9, 0xFFE0356E, 0xFF12B5A6, 0xFF3B82F6, 0xFFF5A524,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CoinSummary> async = ref.watch(coinSummaryProvider);
    final AsyncValue<List<CoinRewardCatalogItem>> catalogAsync =
        ref.watch(coinCatalogProvider);

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: 'Cüzdan yüklənmədi',
          subtitle: e.toString(),
          icon: AppIcons.error,
        ),
        data: (CoinSummary s) {
          final Map<String, int> balanceByCompany = <String, int>{
            for (final CompanyBalance c in s.companies)
              if (c.companyId != null) c.companyId!: c.balance,
          };
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(coinSummaryProvider);
              ref.invalidate(coinCatalogProvider);
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(child: _BalanceHero(total: s.total)),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xl)),
                _section('Coinlərim'),
                if (s.companies.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      child: Text('Hələ heç bir işlətmədə coin yoxdur.',
                          style: AppTextStyles.bodySm),
                    ),
                  )
                else
                  SliverList.separated(
                    itemCount: s.companies.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (BuildContext _, int i) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      child: _CoinTile(
                        row: s.companies[i],
                        color: Color(_palette[i % _palette.length]),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxl)),
                _section('Hədiyyə kataloqu'),
                _catalogSliver(context, catalogAsync, balanceByCompany),
                if (s.recent.isNotEmpty) ...<Widget>[
                  const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xxl)),
                  _section('Son hərəkətlər'),
                  SliverList.separated(
                    itemCount: s.recent.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (BuildContext _, int i) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      child: _TxnTile(txn: s.recent[i]),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxxl)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _catalogSliver(
    BuildContext context,
    AsyncValue<List<CoinRewardCatalogItem>> catalogAsync,
    Map<String, int> balanceByCompany,
  ) {
    return catalogAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text('Kataloq yüklənmədi.', style: AppTextStyles.bodySm),
        ),
      ),
      data: (List<CoinRewardCatalogItem> list) {
        if (list.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Hələ hədiyyə yoxdur. İşlətmələr coinlə alınan '
                'mükafatlar əlavə etdikcə burada görünəcək.',
                style: AppTextStyles.bodySm,
              ),
            ),
          );
        }
        return SliverList.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (BuildContext _, int i) {
            final CoinRewardCatalogItem r = list[i];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _RewardCatalogTile(
                reward: r,
                balanceHere: balanceByCompany[r.companyId] ?? 0,
                onTap: () => context.push('/companies/${r.companyId}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _section(String title) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        sliver: SliverToBoxAdapter(
          child: Text(title, style: AppTextStyles.h2),
        ),
      );
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: kHeroGradient,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(AppRadius.xxl)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x335B21B6),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        top + AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Ümumi balans',
            style: AppTextStyles.bodySm.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(AppIcons.token, color: Colors.white, size: 34),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$total',
                style: AppTextStyles.display.copyWith(
                  color: Colors.white,
                  fontSize: 42,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'coin',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Hər ziyarətdə qazan, hədiyyələrə dəyiş.',
            style: AppTextStyles.bodySm.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinTile extends StatelessWidget {
  const _CoinTile({required this.row, required this.color});

  final CompanyBalance row;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: dark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: dark ? null : AppShadows.sm,
      ),
      child: Row(
        children: <Widget>[
          CompanyLogo(
            name: row.companyName,
            brandColor: color,
            imageUrl: row.logoUrl,
            size: 48,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(row.companyName,
                style: AppTextStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const Icon(AppIcons.token, size: 18, color: AppColors.primary),
          const SizedBox(width: 4),
          Text('${row.balance}',
              style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _RewardCatalogTile extends StatelessWidget {
  const _RewardCatalogTile({
    required this.reward,
    required this.balanceHere,
    required this.onTap,
  });

  final CoinRewardCatalogItem reward;
  final int balanceHere;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool affordable = balanceHere >= reward.coinCost;
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: dark ? AppColors.borderDark : AppColors.border,
            ),
            boxShadow: dark ? null : AppShadows.sm,
          ),
          child: Row(
            children: <Widget>[
              CompanyLogo(
                name: reward.companyName,
                brandColor: AppColors.primary,
                imageUrl: reward.companyLogoUrl,
                size: 48,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(reward.title,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(reward.companyName,
                        style: AppTextStyles.bodySm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      affordable
                          ? 'Hazırdır — kassada QR göstər'
                          : 'Bu işlətmədə balans: $balanceHere',
                      style: AppTextStyles.caption.copyWith(
                        color: affordable
                            ? AppColors.success
                            : AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(AppIcons.token,
                          size: 16,
                          color: affordable
                              ? AppColors.primary
                              : AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text('${reward.coinCost}',
                          style: AppTextStyles.h3.copyWith(
                            color: affordable
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          )),
                    ],
                  ),
                  const Icon(AppIcons.chevron,
                      size: 18, color: AppColors.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.txn});

  final CoinTxn txn;

  @override
  Widget build(BuildContext context) {
    final bool earn = txn.isEarn;
    final Color c = earn ? AppColors.success : AppColors.error;
    return Row(
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(earn ? AppIcons.add : AppIcons.remove,
              size: 18, color: c),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(txn.note ?? (earn ? 'Qazanc' : 'Xərc'),
                  style: AppTextStyles.bodyLg
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if (txn.companyName != null)
                Text(txn.companyName!, style: AppTextStyles.caption),
            ],
          ),
        ),
        Text('${earn ? '+' : ''}${txn.amount}',
            style: AppTextStyles.h3.copyWith(color: c)),
      ],
    );
  }
}
