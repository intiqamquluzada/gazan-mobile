import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/companies_providers.dart';
import '../../domain/business_category.dart';

/// Compact category strip: round icon tiles with a short label beneath
/// (≈ 5–6 visible at once instead of 2–3 wide pills).
///
/// Idle tiles are the category's soft tint with its accent icon; the
/// selected one fills with the accent and gets a white icon.
class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final BusinessCategory? selected = ref.watch(selectedCategoryProvider);

    void select(BusinessCategory? c) =>
        ref.read(selectedCategoryProvider.notifier).state = c;

    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: <Widget>[
          _Tile(
            label: s.all,
            icon: Icons.apps_rounded,
            tint: AppColors.action,
            tintBg: AppColors.surfaceAccent,
            selected: selected == null,
            onTap: () => select(null),
          ),
          for (final BusinessCategory c in BusinessCategory.values)
            _Tile(
              label: c.shortLabelOf(s),
              icon: c.icon,
              tint: c.tint,
              tintBg: c.tintBg,
              selected: selected == c,
              onTap: () => select(selected == c ? null : c),
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.icon,
    required this.tint,
    required this.tintBg,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final Color tintBg;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 34,
        child: SizedBox(
          width: 68,
          child: Column(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? tint : tintBg,
                  shape: BoxShape.circle,
                  boxShadow: selected ? AppShadows.brand(tint) : null,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColors.onDark : tint,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11.5,
                  color: selected ? p.textPrimary : p.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact "Kateqoriya" button for the discover list header. Tapping it
/// opens [showCategoryPicker]; when a category is active the button shows
/// it (in its accent colours) with a small ✕ to clear the filter.
class CategoryButton extends ConsumerWidget {
  const CategoryButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final BusinessCategory? selected = ref.watch(selectedCategoryProvider);
    final AppPalette p = context.palette;
    final bool on = selected != null;

    return Material(
      color: on ? selected.tintBg : p.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.full),
        onTap: () => showCategoryPicker(context),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 7, on ? 6 : 12, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(on ? selected.icon : Icons.tune_rounded,
                    size: 16, color: on ? selected.tint : p.textPrimary),
                const SizedBox(width: 6),
                Text(
                  on ? selected.shortLabelOf(s) : s.category,
                  style: AppTextStyles.bodySm.copyWith(
                    color: on ? selected.tint : p.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (on) ...<Widget>[
                  const SizedBox(width: 2),
                  InkResponse(
                    radius: 14,
                    onTap: () => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = null,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(Icons.close_rounded,
                          size: 16, color: selected.tint),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with every category as a round tile (4 per row). Picking
/// one filters the list and closes the sheet; tapping the active one or
/// "Hamısı" clears the filter.
Future<void> showCategoryPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    // Over the floating nav bar, and sized to its content (no overflow).
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (BuildContext ctx) => Consumer(
      builder: (BuildContext ctx, WidgetRef ref, _) {
        final S s = ref.watch(sProvider);
        final BusinessCategory? selected = ref.watch(selectedCategoryProvider);
        void pick(BusinessCategory? c) {
          ref.read(selectedCategoryProvider.notifier).state = c;
          Navigator.of(ctx).pop();
        }

        final List<Widget> tiles = <Widget>[
          _Tile(
            label: s.all,
            icon: Icons.apps_rounded,
            tint: AppColors.action,
            tintBg: AppColors.surfaceAccent,
            selected: selected == null,
            onTap: () => pick(null),
          ),
          for (final BusinessCategory c in BusinessCategory.values)
            _Tile(
              label: c.shortLabelOf(s),
              icon: c.icon,
              tint: c.tint,
              tintBg: c.tintBg,
              selected: selected == c,
              onTap: () => pick(selected == c ? null : c),
            ),
        ];
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(s.category, style: AppTextStyles.h2),
                ),
                const SizedBox(height: AppSpacing.lg),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.05,
                  children: <Widget>[
                    for (int i = 0; i < tiles.length; i++)
                      // Staggered pop-in.
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(
                            milliseconds:
                                (MediaQuery.maybeDisableAnimationsOf(ctx) ??
                                        false)
                                    ? 0
                                    : 260 + i * 35),
                        curve: Curves.easeOutBack,
                        builder: (BuildContext _, double t, Widget? child) =>
                            Opacity(
                          opacity: t.clamp(0, 1),
                          child: Transform.scale(
                              scale: 0.8 + 0.2 * t, child: child),
                        ),
                        child: tiles[i],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
