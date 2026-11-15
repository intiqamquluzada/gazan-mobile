import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'qazan_logo.dart';

/// Centred brand block for the sign-in / sign-up screens: the Q tile, the
/// "Qazan" word-mark and the platform subtitle.
class BrandHeader extends ConsumerWidget {
  const BrandHeader({super.key, this.logoSize = 64, this.subtitle = true});

  final double logoSize;

  /// Show "Müşteri Sadakat Platformu" under the word-mark.
  final bool subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    return Column(
      children: <Widget>[
        QazanLogo(size: logoSize),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Qazan',
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            color: context.palette.ink,
            fontSize: logoSize * 0.5,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        if (subtitle) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            s.brandSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm
                .copyWith(color: context.palette.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// One-line brand strip — small Q tile + "Qazan" — for screens whose
/// illustration already carries the brand (sign-in, onboarding).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        QazanLogo(size: size, animate: false),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Qazan',
          style: AppTextStyles.h3.copyWith(
            fontSize: size * 0.68,
            color: context.palette.ink,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// White round back button with a soft shadow (auth screens).
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      child: Center(
        child: Material(
          color: p.surface,
          shape: const CircleBorder(),
          elevation: 2,
          shadowColor: AppColors.shadowTint.withValues(alpha: 0.18),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed ?? () => Navigator.of(context).maybePop(),
            child: SizedBox.square(
              dimension: 44,
              child: Icon(Icons.arrow_back_rounded, color: p.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-option pill switch: the selected side is the green gradient with
/// white text, the other side sits on a soft neutral track.
class PillToggle<T> extends StatelessWidget {
  const PillToggle({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<({T value, IconData icon, String label})> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final ({T value, IconData icon, String label}) o in options)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(o.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    gradient: o.value == value
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.actionGradient,
                          )
                        : null,
                    boxShadow: o.value == value
                        ? AppShadows.brand(AppColors.action)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        o.icon,
                        size: 18,
                        color: o.value == value
                            ? AppColors.onDark
                            : p.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          o.label,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: o.value == value
                                ? AppColors.onDark
                                : p.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
