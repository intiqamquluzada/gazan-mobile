import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icons.dart';

/// Calm, centered empty / error placeholder. A soft tinted disc with a
/// single line icon — never an illustration or emoji.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = AppIcons.emptyBox,
    this.action,
    this.image,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  /// Optional 3D illustration (asset path) shown instead of the icon disc.
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (image != null)
              Image.asset(image!, width: 210, filterQuality: FilterQuality.medium)
            else
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.caramelSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.action, size: 34),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: image != null
                  ? AppTextStyles.h1.copyWith(
                      color: context.palette.ink, fontWeight: FontWeight.w800)
                  : AppTextStyles.h3,
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm,
              ),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
