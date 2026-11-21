import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Segmented "pill" tabs: a soft track with the selected tab as the green
/// gradient pill (the indicator itself comes from the app's TabBar theme).
/// Drop-in for `TabBar` in an AppBar `bottom` or at the top of a body.
class PillTabBar extends StatelessWidget implements PreferredSizeWidget {
  const PillTabBar({super.key, required this.tabs, this.controller});

  final List<String> tabs;
  final TabController? controller;

  static const double _height = 48;

  @override
  Size get preferredSize => const Size.fromHeight(_height + AppSpacing.md * 2);

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.md),
      child: Container(
        height: _height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: AppShadows.sm,
        ),
        child: TabBar(
          controller: controller,
          tabs: <Widget>[for (final String t in tabs) Tab(text: t, height: 40)],
        ),
      ),
    );
  }
}
