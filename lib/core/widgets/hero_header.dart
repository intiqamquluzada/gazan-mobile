import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// The brand "hero" surface — a light latte gradient band with rounded
/// bottom corners that anchors the top of primary screens (Discover,
/// Cards, Rewards). It replaces the old flat white app bar and is the
/// app's strongest piece of visual identity.
///
/// [title] is rendered large and dark; [subtitle] sits beneath it.
/// [actions] are placed top-right (e.g. notifications). [bottom] is an
/// optional slot — pass a search field or a balance row and it will sit
/// flush at the bottom of the band, overlapping the content below.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.bottom,
    this.leading,
    this.bottomInset = 0,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? bottom;
  final Widget? leading;

  /// Extra empty space under the content — reserves room for a widget
  /// the caller floats over the band's bottom edge (e.g. search pill).
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroLightGradient,
        ),
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(AppRadius.xxl)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadowTint.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        topInset + AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (leading != null) ...<Widget>[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTextStyles.h1
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.caramelText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              for (final Widget a in actions) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                a,
              ],
            ],
          ),
          if (bottom != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            bottom!,
          ],
        ],
      ),
    );
  }
}

/// Circular translucent icon button sized for the hero band (notifications,
/// favourites). Glassy fill so it sits on the gradient without a hard edge.
class HeroIconButton extends StatelessWidget {
  const HeroIconButton({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.75),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child:
              Center(child: Icon(icon, color: AppColors.textPrimary, size: 22)),
        ),
      ),
    );
  }
}
