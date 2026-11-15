import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_icons.dart';

/// 5-tab customer shell. NFC sits dead-centre as the raised brand action:
/// Discover · Places · NFC · Cards · Profile.
class CustomerShell extends ConsumerWidget {
  const CustomerShell({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = <String>[
    '/home',
    '/companies',
    '/nfc',
    '/cards',
    '/profile',
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
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final String location = GoRouterState.of(context).uri.toString();
    final int currentIdx = _indexFor(location);
    final List<AppNavItem> items = <AppNavItem>[
      AppNavItem(
          label: s.tabHome,
          icon: AppIcons.home,
          activeIcon: AppIcons.homeActive),
      AppNavItem(
          label: s.tabCompanies,
          icon: Icons.storefront_outlined,
          activeIcon: AppIcons.store),
      const AppNavItem(
          label: '',
          icon: AppIcons.nfc,
          activeIcon: AppIcons.nfc,
          prominent: true),
      AppNavItem(
          label: s.tabCards,
          icon: AppIcons.cards,
          activeIcon: AppIcons.cardsActive),
      AppNavItem(
          label: s.tabProfile,
          icon: AppIcons.profile,
          activeIcon: AppIcons.profileActive),
    ];
    return PopScope(
      canPop: currentIdx == 0,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) return;
        context.go(_routes[0]);
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: AppBottomNav(
          items: items,
          currentIndex: currentIdx,
          onSelect: (int i) => context.go(_routes[i]),
        ),
      ),
    );
  }
}
