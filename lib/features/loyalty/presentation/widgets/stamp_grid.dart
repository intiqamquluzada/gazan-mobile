import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_icons.dart';

/// Visualizes a customer's stamps for a single loyalty card.
///
/// Filled stamps are gold ([AppColors.reward]); empty ones a soft light
/// tone. The last slot is the reward slot (gift icon). A stamp that turns
/// filled while on screen "pops" (0.8 → 1.1 → 1.0, ~300 ms) unless the
/// system asks for reduced motion.
class StampGrid extends StatelessWidget {
  const StampGrid({
    super.key,
    required this.stamps,
    required this.required,
    this.onDark = true,
    this.compact = false,
  });

  final int stamps;
  final int required;

  /// True when drawn on a dark card (empty dots use a translucent light
  /// tone); false on light surfaces (empty dots use [AppColors.stampEmpty]).
  final bool onDark;
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
            onDark: onDark,
          ),
      ],
    );
  }
}

class _StampDot extends StatefulWidget {
  const _StampDot({
    required this.size,
    required this.filled,
    required this.isRewardSlot,
    required this.onDark,
  });

  final double size;
  final bool filled;
  final bool isRewardSlot;
  final bool onDark;

  @override
  State<_StampDot> createState() => _StampDotState();
}

class _StampDotState extends State<_StampDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );

  // 0.8 → 1.1 → 1.0
  late final Animation<double> _scale = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.8, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ],
  ).animate(_pop);

  @override
  void didUpdateWidget(covariant _StampDot old) {
    super.didUpdateWidget(old);
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!old.filled && widget.filled && !reduceMotion) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    final Color emptyFill = widget.onDark
        ? AppColors.onDark.withValues(alpha: 0.14)
        : context.palette.stampEmpty;
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final Widget dot = AnimatedContainer(
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.filled ? AppColors.reward : emptyFill,
        shape: BoxShape.circle,
        border: widget.isRewardSlot && !widget.filled
            ? Border.all(
                color: AppColors.reward.withValues(alpha: 0.8),
                width: 1.6,
                strokeAlign: BorderSide.strokeAlignInside,
              )
            : null,
      ),
      child: widget.filled
          ? Icon(
              widget.isRewardSlot ? AppIcons.gift : AppIcons.check,
              size: size * 0.55,
              color: AppColors.onReward,
            )
          : widget.isRewardSlot
              ? Icon(AppIcons.gift, size: size * 0.55, color: AppColors.reward)
              : null,
    );

    return ScaleTransition(scale: _scale, child: dot);
  }
}
