import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../../wallet/application/wallet_providers.dart';
import '../../wallet/domain/coin_summary.dart';
import '../application/loyalty_providers.dart';
import '../domain/loyalty_card.dart';
import '../domain/loyalty_program.dart';
import 'widgets/loyalty_card_widget.dart';

class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LoyaltyCard>> cards = ref.watch(myCardsProvider);
    final AsyncValue<CoinSummary> coins = ref.watch(coinSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartlarım'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () {
              ref.invalidate(myCardsProvider);
              ref.invalidate(coinSummaryProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myCardsProvider);
          ref.invalidate(coinSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.huge,
          ),
          children: <Widget>[
            _CoinBalanceCard(coinsAsync: coins),
            const SizedBox(height: AppSpacing.xl),
            Text('Sadiqlik kartları', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            cards.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object e, _) => EmptyState(
                title: 'Xəta',
                subtitle: e.toString(),
                icon: AppIcons.error,
              ),
              data: (List<LoyaltyCard> list) {
                if (list.isEmpty) {
                  return EmptyState(
                    title: 'Hələ kartın yoxdur',
                    subtitle:
                        'Kəşf et səhifəsindən sevimli yerini tap və kartını al.',
                    icon: AppIcons.gift,
                    action: PrimaryButton(
                      label: 'Kəşf et',
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
      ),
    );
  }
}

/// Coin balance hero + per-business breakdown — relocated here from the
/// old Cüzdan tab. Tapping a row jumps to that business's page where
/// "Coinlə al" lives.
class _CoinBalanceCard extends StatelessWidget {
  const _CoinBalanceCard({required this.coinsAsync});

  final AsyncValue<CoinSummary> coinsAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kHeroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: coinsAsync.when(
        loading: () => SizedBox(
          height: 80,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white
                  .withValues(alpha: 0.8)),
            ),
          ),
        ),
        error: (Object e, _) => Text(
          'Coin balansı yüklənmədi',
          style: AppTextStyles.bodySm.copyWith(color: Colors.white),
        ),
        data: (CoinSummary s) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Coin balansım',
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                )),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                const Icon(AppIcons.token, color: Colors.white, size: 28),
                const SizedBox(width: AppSpacing.sm),
                Text('${s.total}',
                    style: AppTextStyles.display.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    )),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('coin',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      )),
                ),
              ],
            ),
            if (s.companies.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final CompanyBalance c in s.companies)
                    _CoinPill(name: c.companyName, balance: c.balance),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.name, required this.balance});

  final String name;
  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(AppIcons.token, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text('$balance',
              style: AppTextStyles.bodySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                )),
          ),
        ],
      ),
    );
  }
}

class _CardEntry extends ConsumerWidget {
  const _CardEntry({required this.card});

  final LoyaltyCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Company?> companyAsync =
        ref.watch(companyByIdProvider(card.companyId));

    return companyAsync.when(
      loading: () => const _CardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (Company? company) {
        if (company == null) return const SizedBox.shrink();
        return FutureBuilder<LoyaltyProgram?>(
          future: ref
              .read(loyaltyRepositoryProvider)
              .programById(card.programId),
          builder: (BuildContext _, AsyncSnapshot<LoyaltyProgram?> snap) {
            final LoyaltyProgram? program = snap.data;
            if (program == null) return const _CardSkeleton();
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
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(AppIcons.gift,
                            color: AppColors.success),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${card.rewardsAvailable} mükafat səni gözləyir!',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/qr'),
                          child: const Text('QR'),
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

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    );
  }
}

