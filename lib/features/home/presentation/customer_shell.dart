import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_icons.dart';

/// 5-tab customer shell. QR sits dead-centre as the raised brand action:
/// İşlətmələr · Cüzdan · QR · Kampaniyalar · Profil.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = <String>[
    '/home',
    '/wallet',
    '/qr',
    '/campaigns',
    '/profile',
  ];

  static const List<AppNavItem> _items = <AppNavItem>[
    AppNavItem(
      label: AppStrings.tabHome,
      icon: AppIcons.home,
      activeIcon: AppIcons.homeActive,
    ),
    AppNavItem(
      label: 'Cüzdan',
      icon: AppIcons.token,
      activeIcon: AppIcons.token,
    ),
    AppNavItem(
      label: '',
      icon: AppIcons.qr,
      activeIcon: AppIcons.qr,
      prominent: true,
    ),
    AppNavItem(
      label: 'Kampaniyalar',
      icon: AppIcons.programs,
      activeIcon: AppIcons.programsActive,
    ),
    AppNavItem(
      label: AppStrings.tabProfile,
      icon: AppIcons.profile,
      activeIcon: AppIcons.profileActive,
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
