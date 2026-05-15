import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Visualizes a customer's stamps for a single loyalty card.
///
/// The last slot is highlighted as the reward slot.
class StampGrid extends StatelessWidget {
  const StampGrid({
    super.key,
    required this.stamps,
    required this.required,
    this.brand = Colors.white,
    this.onSurface = Colors.white,
    this.compact = false,
  });

  final int stamps;
  final int required;
  final Color brand;
  final Color onSurface;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 22 : 36;
    return Wrap(
      spacing: compact ? 6 : AppSpacing.sm,
      runSpacing: compact ? 6 : AppSpacing.sm,
      children: <Widget>[
        for (int i = 0; i < required; i++)
          _StampDot(
            size: size,
            filled: i < stamps,
            isRewardSlot: i == required - 1,
            onSurface: onSurface,
          ),
      ],
    );
  }
}

class _StampDot extends StatelessWidget {
  const _StampDot({
    required this.size,
    required this.filled,
    required this.isRewardSlot,
    required this.onSurface,
  });

  final double size;
  final bool filled;
  final bool isRewardSlot;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    final Color border = onSurface.withValues(alpha: 0.55);
    final Color fillBg = onSurface.withValues(alpha: 0.95);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? fillBg : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isRewardSlot && !filled ? onSurface : border,
          width: isRewardSlot && !filled ? 1.6 : 1.2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: filled
          ? Icon(
              isRewardSlot ? Icons.card_giftcard_rounded : Icons.check_rounded,
              size: size * 0.55,
              color: Theme.of(context).colorScheme.surface,
            )
          : isRewardSlot
              ? Icon(Icons.card_giftcard_rounded,
                  size: size * 0.55, color: onSurface)
              : null,
    );
  }
}
