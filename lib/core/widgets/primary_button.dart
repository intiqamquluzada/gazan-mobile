import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Primary CTA. Defaults to filled-orange with a soft brand glow — use
/// [variant] for the tonal / outlined alternatives.
enum PrimaryButtonVariant { filled, tonal, outlined }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expanded = true,
    this.variant = PrimaryButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expanded;
  final PrimaryButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final Widget child = loading
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final Widget button = switch (variant) {
      PrimaryButtonVariant.filled => FilledButton(
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      PrimaryButtonVariant.tonal => FilledButton.tonal(
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      PrimaryButtonVariant.outlined => OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: child,
        ),
    };

    final bool glow = variant == PrimaryButtonVariant.filled &&
        onPressed != null &&
        !loading;

    return Container(
      width: expanded ? double.infinity : null,
      decoration: glow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.brand(AppColors.primary),
            )
          : null,
      child: button,
    );
  }
}
