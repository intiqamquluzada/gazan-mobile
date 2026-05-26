import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// One destination in [AppBottomNav]. Set [prominent] on the primary
/// action (QR / Scan) — it renders as a raised, filled brand disc, the
/// app's signature navigation element.
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.prominent = false,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool prominent;
}

/// Custom bottom navigation: a clean white shelf with a soft top shadow,
/// one weight of line icon, a slim active indicator, and a single raised
/// brand-colored action. Deliberately not Material's [NavigationBar] —
/// that flat default was a big part of why the old UI looked generic.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: dark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: dark ? 0.0 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavCell(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (item.prominent) return _ProminentCell(item: item, onTap: onTap);

    final Color tint =
        selected ? AppColors.primary : AppColors.textTertiary;
    return InkResponse(
      onTap: onTap,
      radius: 36,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(selected ? item.activeIcon : item.icon,
              size: 24, color: tint),
          const SizedBox(height: 5),
          Text(
            item.label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: tint,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: selected ? 18 : 0,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProminentCell extends StatelessWidget {
  const _ProminentCell({required this.item, required this.onTap});

  final AppNavItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 40,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Transform.translate(
            offset: const Offset(0, -2),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: kHeroGradient,
                shape: BoxShape.circle,
                boxShadow: AppShadows.brand(AppColors.primary),
              ),
              child: Icon(item.activeIcon, color: Colors.white, size: 26),
            ),
          ),
          if (item.label.isNotEmpty) ...<Widget>[
            const SizedBox(height: 3),
            Text(
              item.label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
