import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_icons.dart';

/// Bottom-nav shell for the business experience. The Scan tab is the
/// raised brand action.
class BusinessShell extends StatelessWidget {
  const BusinessShell({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = <String>[
    '/business',
    '/business/customers',
    '/business/scan',
    '/business/programs',
    '/business/profile',
  ];

  static const List<AppNavItem> _items = <AppNavItem>[
    AppNavItem(
      label: AppStrings.tabDashboard,
      icon: AppIcons.dashboard,
      activeIcon: AppIcons.dashboardActive,
    ),
    AppNavItem(
      label: AppStrings.tabCustomers,
      icon: AppIcons.customers,
      activeIcon: AppIcons.customersActive,
    ),
    AppNavItem(
      label: AppStrings.tabScan,
      icon: AppIcons.qr,
      activeIcon: AppIcons.qr,
      prominent: true,
    ),
    AppNavItem(
      label: AppStrings.tabPrograms,
      icon: AppIcons.programs,
      activeIcon: AppIcons.programsActive,
    ),
    AppNavItem(
      label: 'Biznesim',
      icon: AppIcons.store,
      activeIcon: AppIcons.store,
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
