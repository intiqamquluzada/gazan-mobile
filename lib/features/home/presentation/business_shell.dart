import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_icons.dart';

/// Bottom-nav shell for the business experience. The Scan tab is the
/// raised brand action.
class BusinessShell extends ConsumerWidget {
  const BusinessShell({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = <String>[
    '/business',
    '/business/customers',
    '/business/scan',
    '/business/programs',
    '/business/profile',
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
          label: s.tabDashboard,
          icon: AppIcons.dashboard,
          activeIcon: AppIcons.dashboardActive),
      AppNavItem(
          label: s.tabCustomers,
          icon: AppIcons.customers,
          activeIcon: AppIcons.customersActive),
      AppNavItem(
          label: s.tabScan,
          icon: AppIcons.qr,
          activeIcon: AppIcons.qr,
          prominent: true),
      AppNavItem(
          label: s.tabPrograms,
          icon: AppIcons.programs,
          activeIcon: AppIcons.programsActive),
      AppNavItem(
          label: s.tabMyBusiness,
          icon: AppIcons.store,
          activeIcon: AppIcons.store),
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
