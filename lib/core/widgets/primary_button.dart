import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Primary CTA. Defaults to the green gradient with a soft brand glow — use
/// [variant] for the tonal / outlined alternatives.
enum PrimaryButtonVariant { filled, tonal, outlined }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expanded = true,
    this.variant = PrimaryButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Icon pinned to the right edge (e.g. an arrow on "Sign in").
  final IconData? trailingIcon;
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
              color: AppColors.onDark,
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
    final Widget content = trailingIcon == null || loading
        ? child
        : Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: child,
              ),
              Positioned(
                right: 0,
                child: Icon(trailingIcon, size: 22),
              ),
            ],
          );

    final Widget button = switch (variant) {
      PrimaryButtonVariant.filled => FilledButton(
          onPressed: loading ? null : onPressed,
          child: content,
        ),
      // Secondary: mint fill, green text, flat (no gradient from the theme).
      PrimaryButtonVariant.tonal => FilledButton.tonal(
          style: ButtonStyle(
            backgroundBuilder: (_, __, Widget? c) =>
                c ?? const SizedBox.shrink(),
            backgroundColor: WidgetStateProperty.resolveWith(
                (Set<WidgetState> s) => s.contains(WidgetState.disabled)
                    ? context.palette.surfaceMuted
                    : context.palette.caramelSoft),
            foregroundColor:
                WidgetStatePropertyAll(context.palette.caramelText),
          ),
          onPressed: loading ? null : onPressed,
          child: content,
        ),
      PrimaryButtonVariant.outlined => OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: content,
        ),
    };

    final bool glow =
        variant == PrimaryButtonVariant.filled && onPressed != null && !loading;

    return Container(
      width: expanded ? double.infinity : null,
      decoration: glow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: AppShadows.brand(AppColors.action),
            )
          : null,
      child: button,
    );
  }
}
