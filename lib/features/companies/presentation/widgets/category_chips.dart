import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/companies_providers.dart';
import '../../domain/business_category.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BusinessCategory? selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        children: <Widget>[
          _Chip(
            label: AppStrings.all,
            icon: Icons.apps_rounded,
            tint: AppColors.primary,
            selected: selected == null,
            onTap: () => ref
                .read(selectedCategoryProvider.notifier)
                .state = null,
          ),
          for (final BusinessCategory c in BusinessCategory.values) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            _Chip(
              label: c.label,
              icon: c.icon,
              tint: c.tint,
              selected: selected == c,
              onTap: () => ref
                  .read(selectedCategoryProvider.notifier)
                  .state = (selected == c) ? null : c,
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg =
        selected ? tint : Theme.of(context).colorScheme.surface;
    final Color fg = selected ? Colors.white : tint;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.full),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? tint : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.bodySm.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
