import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/promotions_providers.dart';
import '../../domain/promotion.dart';

/// Horizontal carousel of promo banner cards.
class PromotionsCarousel extends ConsumerWidget {
  const PromotionsCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Promotion>> async = ref.watch(promotionsProvider);

    return SizedBox(
      height: 175,
      child: async.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (List<Promotion> list) {
          if (list.isEmpty) return const SizedBox.shrink();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (BuildContext _, int i) =>
                _PromoCard(promo: list[i]),
          );
        },
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});

  final Promotion promo;

  String? _countdown() {
    if (promo.endsAt == null) return null;
    final Duration remaining = promo.endsAt!.difference(DateTime.now());
    if (remaining.isNegative) return null;
    if (remaining.inDays > 0) return '${remaining.inDays} gün qalıb';
    if (remaining.inHours > 0) return '${remaining.inHours} saat qalıb';
    return '${remaining.inMinutes} dəq qalıb';
  }

  @override
  Widget build(BuildContext context) {
    final String? countdown = _countdown();
    return SizedBox(
      width: 290,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          if (promo.companyId != null) {
            context.push('/companies/${promo.companyId}');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(promo.gradientStartHex),
                Color(promo.gradientEndHex),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(promo.gradientStartHex).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -8,
                bottom: -10,
                child: Text(
                  promo.emoji,
                  style: TextStyle(
                    fontSize: 96,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          promo.tag,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (countdown != null)
                        Row(
                          children: <Widget>[
                            const Icon(Icons.schedule_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              countdown,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        promo.title,
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.subtitle,
                        style: AppTextStyles.bodySm.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          promo.cta,
                          style: AppTextStyles.bodySm.copyWith(
                            color: Color(promo.gradientStartHex),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(promo.gradientStartHex),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
