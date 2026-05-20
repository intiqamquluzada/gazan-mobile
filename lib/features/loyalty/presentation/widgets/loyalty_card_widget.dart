import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../companies/domain/company.dart';
import '../../domain/loyalty_card.dart';
import '../../domain/loyalty_program.dart';
import 'stamp_grid.dart';

/// The visual "punch card" — used both on the My Cards list and on the
/// company detail page.
class LoyaltyCardWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final Color brand = Color(company.coverColorHex);
    final int stamps = card?.stamps ?? 0;
    final int required = program.stampsRequired;
    final int rewards = card?.rewardsAvailable ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[brand, _darken(brand, 0.18)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: brand.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    company.name.initials,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(company.name,
                          style: AppTextStyles.h3.copyWith(color: Colors.white)),
                      Text(program.title,
                          style: AppTextStyles.bodySm.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          )),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(AppIcons.gift,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('$rewards',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            StampGrid(stamps: stamps, required: required),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  rewards > 0
                      ? '$rewards mükafat hazırdır'
                      : '$stamps / $required möhür',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(program.rewardLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _darken(Color color, double amount) {
    final HSLColor hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
