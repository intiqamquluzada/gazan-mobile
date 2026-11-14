import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../companies/application/companies_providers.dart';
import '../../companies/domain/company.dart';
import '../../reviews/application/reviews_providers.dart';
import '../../reviews/domain/review.dart';

/// Business → "Rəylər": the average rating, a 5→1 star breakdown and every
/// review customers left for the owner's venue (read-only).
class BusinessReviewsScreen extends ConsumerWidget {
  const BusinessReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final Company? company = ref.watch(myCompanyProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(s.reviewsWord)),
      body: company == null
          ? const Center(child: CircularProgressIndicator())
          : _Body(companyId: company.id),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final AsyncValue<CompanyReviews> async =
        ref.watch(companyReviewsProvider(companyId));
    final AppPalette p = context.palette;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(companyReviewsProvider(companyId)),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ListView(
          children: <Widget>[EmptyState(title: s.reviewsNotLoaded)],
        ),
        data: (CompanyReviews r) {
          final List<int> dist = List<int>.filled(5, 0);
          for (final Review rev in r.reviews) {
            if (rev.rating >= 1 && rev.rating <= 5) dist[rev.rating - 1]++;
          }
          final int maxCount =
              dist.fold<int>(0, (int a, int b) => a > b ? a : b);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: <Widget>[
              // Summary card
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: AppShadows.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(r.average.toStringAsFixed(1),
                            style: AppTextStyles.display),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (int i = 1; i <= 5; i++)
                              Icon(
                                i <= r.average.round()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 16,
                                color: AppColors.reward,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${r.count} ${s.reviewsWord.toLowerCase()}',
                            style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          for (int star = 5; star >= 1; star--)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 14,
                                    child: Text('$star',
                                        style: AppTextStyles.caption),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: maxCount == 0
                                            ? 0
                                            : dist[star - 1] / maxCount,
                                        minHeight: 6,
                                        color: AppColors.reward,
                                        backgroundColor: p.progressTrack,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 22,
                                    child: Text('${dist[star - 1]}',
                                        textAlign: TextAlign.end,
                                        style: AppTextStyles.caption),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (r.reviews.isEmpty)
                EmptyState(
                  title: s.noReviewsYet,
                  icon: Icons.rate_review_outlined,
                )
              else
                for (final Review rev in r.reviews)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: p.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(rev.userName,
                                  style: AppTextStyles.body
                                      .copyWith(fontWeight: FontWeight.w600)),
                            ),
                            for (int i = 1; i <= 5; i++)
                              Icon(
                                i <= rev.rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 14,
                                color: AppColors.reward,
                              ),
                          ],
                        ),
                        if ((rev.comment ?? '').isNotEmpty) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(rev.comment!, style: AppTextStyles.bodySm),
                        ],
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
