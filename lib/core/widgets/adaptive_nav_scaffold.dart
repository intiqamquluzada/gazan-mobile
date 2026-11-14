import 'package:flutter/material.dart';

import 'app_bottom_nav.dart';

/// Bottom navigation on a phone, a side rail with centred, width-limited
/// content on a tablet or desktop window.
class AdaptiveNavScaffold extends StatelessWidget {
  const AdaptiveNavScaffold({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
    required this.child,
  });

  static const double wideBreakpoint = 900;
  static const double _maxContentWidth = 1200;

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width < wideBreakpoint) {
      return Scaffold(
        body: child,
        bottomNavigationBar: AppBottomNav(
          items: items,
          currentIndex: currentIndex,
          onSelect: onSelect,
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                for (final AppNavItem item in items)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: Text(item.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: _maxContentWidth),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
