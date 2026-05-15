import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';

class BusinessShell extends StatelessWidget {
  const BusinessShell({super.key, required this.child});

  final Widget child;

  static const List<_Tab> _tabs = <_Tab>[
    _Tab('/business', AppStrings.tabDashboard,
        Icons.dashboard_outlined, Icons.dashboard_rounded),
    _Tab('/business/scan', AppStrings.tabScan,
        Icons.qr_code_scanner_outlined, Icons.qr_code_scanner_rounded),
    _Tab('/business/customers', AppStrings.tabCustomers,
        Icons.group_outlined, Icons.group_rounded),
    _Tab('/business/programs', AppStrings.tabPrograms,
        Icons.tune_outlined, Icons.tune_rounded),
  ];

  int _indexFor(String location) {
    int best = 0;
    int bestLen = 0;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].location) &&
          _tabs[i].location.length > bestLen) {
        best = i;
        bestLen = _tabs[i].location.length;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int currentIndex = _indexFor(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int i) => context.go(_tabs[i].location),
        destinations: <NavigationDestination>[
          for (final _Tab t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.iconActive),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

class _Tab {
  const _Tab(this.location, this.label, this.icon, this.iconActive);
  final String location;
  final String label;
  final IconData icon;
  final IconData iconActive;
}
