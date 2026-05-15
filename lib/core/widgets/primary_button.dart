import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Primary CTA. Defaults to filled-orange — use [variant] for alternatives.
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
    return SizedBox(
      width: expanded ? double.infinity : null,
      child: button,
    );
  }
}
