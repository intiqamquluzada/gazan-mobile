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
    '/cards',
    '/profile',
  ];

  static const List<AppNavItem> _items = <AppNavItem>[
    AppNavItem(
      label: AppStrings.tabHome,
      icon: AppIcons.home,
      activeIcon: AppIcons.homeActive,
    ),
    AppNavItem(
      label: 'Hədiyyə',
      icon: AppIcons.gift,
      activeIcon: AppIcons.gift,
    ),
    AppNavItem(
      label: '',
      icon: AppIcons.qr,
      activeIcon: AppIcons.qr,
      prominent: true,
    ),
    AppNavItem(
      label: AppStrings.tabCards,
      icon: AppIcons.cards,
      activeIcon: AppIcons.cardsActive,
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
    final int currentIdx = _indexFor(location);
    // Back button:
    //   - On the home tab → let the OS pop (exits the app cleanly).
    //   - On any other tab → switch back to the home tab first, so
    //     users don't accidentally drop out of the app from a deep
    //     destination.
    return PopScope(
      canPop: currentIdx == 0,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) return;
        context.go(_routes[0]);
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: AppBottomNav(
          items: _items,
          currentIndex: currentIdx,
          onSelect: (int i) => context.go(_routes[i]),
        ),
      ),
    );
  }
}
