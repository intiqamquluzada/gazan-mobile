import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';

/// Bottom-nav shell for the customer experience. Holds the four core tabs.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.child});

  final Widget child;

  static const List<_Tab> _tabs = <_Tab>[
    _Tab('/home', AppStrings.tabHome,
        Icons.explore_outlined, Icons.explore_rounded),
    _Tab('/cards', AppStrings.tabCards,
        Icons.card_giftcard_outlined, Icons.card_giftcard_rounded),
    _Tab('/qr', AppStrings.tabQr,
        Icons.qr_code_2_outlined, Icons.qr_code_2_rounded),
    _Tab('/profile', AppStrings.tabProfile,
        Icons.person_outline_rounded, Icons.person_rounded),
  ];

  int _indexFor(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].location)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final String location =
        GoRouterState.of(context).uri.toString();
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
