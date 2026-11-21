import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/company_logo.dart';
import '../../../companies/domain/company.dart';
import '../../domain/loyalty_card.dart';
import '../../domain/loyalty_program.dart';
import 'stamp_grid.dart';

/// The visual "punch card" — used both on the My Cards list and on the
/// company detail page.
class LoyaltyCardWidget extends ConsumerWidget {
  const LoyaltyCardWidget({
    super.key,
    required this.company,
    required this.program,
    this.card,
    this.onTap,
  });

  final Company company;
  final LoyaltyProgram program;
  final LoyaltyCard? card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final Color brand = Color(company.coverColorHex);
    final int stamps = card?.stamps ?? 0;
    final int required = program.stampsToFill(card);
    final int rewards = card?.rewardsAvailable ?? 0;
    final AppPalette p = context.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          // White card; green carries the venue name and the reward slot.
          color: p.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CompanyLogo(
                  name: company.name,
                  brandColor: brand,
                  imageUrl: company.logoUrl,
                  size: 44,
                  radius: AppRadius.md,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(company.name,
                          style: AppTextStyles.h3.copyWith(
                              color: p.caramelText,
                              fontWeight: FontWeight.w800)),
                      Text(program.title,
                          style: AppTextStyles.bodySm
                              .copyWith(color: p.textSecondary)),
                    ],
                  ),
                ),
                if (rewards > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.reward,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(AppIcons.gift,
                            size: 14, color: AppColors.onReward),
                        const SizedBox(width: 4),
                        Text('$rewards',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.onReward,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                if (onTap != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.chevron_right_rounded, color: p.textPrimary),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            StampGrid(stamps: stamps, required: required, onDark: false),
            const SizedBox(height: AppSpacing.md),
            // Progress toward the next reward.
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: required == 0 ? 0 : (stamps / required).clamp(0, 1),
                minHeight: 5,
                color: p.caramel,
                backgroundColor: p.progressTrack,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  rewards > 0
                      ? '$rewards ${s.rewardWord} ${s.readyWord}'
                      : '$stamps / $required ${s.stampWord}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(program.rewardLabelOf(s, currency: company.currency),
                    style: AppTextStyles.caption.copyWith(
                      color: p.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
