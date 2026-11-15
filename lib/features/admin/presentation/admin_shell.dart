import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/widgets/adaptive_nav_scaffold.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_icons.dart';

/// Bottom-nav shell for the platform admin experience. Mirrors the
/// customer/business shells — one role, one shell.
class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = <String>[
    '/admin',
    '/admin/users',
    '/admin/businesses',
    '/admin/coins',
    '/admin/notifications',
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
          label: s.tabPanel,
          icon: AppIcons.dashboard,
          activeIcon: AppIcons.dashboardActive),
      AppNavItem(
          label: s.tabUsers,
          icon: AppIcons.customers,
          activeIcon: AppIcons.customersActive),
      AppNavItem(
          label: s.tabBusinesses,
          icon: AppIcons.store,
          activeIcon: AppIcons.store),
      AppNavItem(
          label: s.tabCoins, icon: AppIcons.token, activeIcon: AppIcons.token),
      AppNavItem(
          label: s.tabNotify, icon: AppIcons.bell, activeIcon: AppIcons.bell),
    ];
    return PopScope(
      // Only the first tab's own page may exit the app; sub-pages that
      // fall back to index 0 (e.g. NFC, analytics) return to it instead.
      canPop: GoRouterState.of(context).uri.path == _routes[0],
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) return;
        context.go(_routes[0]);
      },
      child: AdaptiveNavScaffold(
        items: items,
        currentIndex: currentIdx,
        onSelect: (int i) => context.go(_routes[i]),
        child: child,
      ),
    );
  }
}
