import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_icons.dart';

/// Bottom-nav shell for the platform admin experience. Mirrors the
/// customer/business shells — one role, one shell.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = <String>[
    '/admin',
    '/admin/users',
    '/admin/businesses',
    '/admin/coins',
  ];

  static const List<AppNavItem> _items = <AppNavItem>[
    AppNavItem(
      label: 'Panel',
      icon: AppIcons.dashboard,
      activeIcon: AppIcons.dashboardActive,
    ),
    AppNavItem(
      label: 'İstifadəçilər',
      icon: AppIcons.customers,
      activeIcon: AppIcons.customersActive,
    ),
    AppNavItem(
      label: 'Biznes',
      icon: AppIcons.store,
      activeIcon: AppIcons.store,
    ),
    AppNavItem(
      label: 'Coin',
      icon: AppIcons.token,
      activeIcon: AppIcons.token,
    ),
  ];

  int _indexFor(String location) {
    int best = 0;
    int bestLen = 0;
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i]) && _routes[i].length > bestLen) {
        best = i;
        bestLen = _routes[i].length;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        items: _items,
        currentIndex: _indexFor(location),
        onSelect: (int i) => context.go(_routes[i]),
      ),
    );
  }
}
