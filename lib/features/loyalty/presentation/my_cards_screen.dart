import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../application/loyalty_providers.dart';
import '../domain/loyalty_card.dart';
import '../domain/loyalty_program.dart';
import 'widgets/loyalty_card_widget.dart';

class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LoyaltyCard>> cards = ref.watch(myCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sadiqlik kartlarım'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(myCardsProvider),
          ),
        ],
      ),
      body: cards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          title: 'Xəta', subtitle: e.toString(),
          icon: Icons.error_outline_rounded,
        ),
        data: (List<LoyaltyCard> list) {
          if (list.isEmpty) {
            return EmptyState(
              title: 'Hələ kartın yoxdur',
              subtitle: 'Kəşf et səhifəsindən sevimli yerini tap və kartını al.',
              icon: Icons.card_giftcard_outlined,
              action: PrimaryButton(
                label: 'Kəşf et',
                icon: Icons.explore_outlined,
                expanded: false,
                onPressed: () => context.go('/home'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myCardsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.huge,
              ),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.lg),
              itemBuilder: (BuildContext context, int i) =>
                  _CardEntry(card: list[i]),
            ),
          );
        },
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
                        const Icon(Icons.celebration_rounded,
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
