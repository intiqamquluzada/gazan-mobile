import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/widgets/adaptive_nav_scaffold.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_icons.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user_role.dart';
import '../../business/presentation/counter_watcher.dart';

/// Navigation for the business experience: the owner's five tabs with the
/// till in the centre, or just the till and manual entry for a cashier.
class BusinessShell extends ConsumerWidget {
  const BusinessShell({super.key, required this.child});

  final Widget child;

  static const List<String> _ownerRoutes = <String>[
    '/business',
    '/business/customers',
    '/business/scan',
    '/business/programs',
    '/business/profile',
  ];

  static const List<String> _cashierRoutes = <String>[
    '/business/scan',
    '/business/manual',
  ];

  int _indexFor(List<String> routes, String location) {
    int best = 0;
    int bestLen = 0;
    for (int i = 0; i < routes.length; i++) {
      if (location.startsWith(routes[i]) && routes[i].length > bestLen) {
        best = i;
        bestLen = routes[i].length;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S s = ref.watch(sProvider);
    final bool cashier = ref.watch(currentUserProvider)?.role == UserRole.cashier;
    final List<String> routes = cashier ? _cashierRoutes : _ownerRoutes;
    final String location = GoRouterState.of(context).uri.toString();
    final int currentIdx = _indexFor(routes, location);
    final AppNavItem till = AppNavItem(
      label: s.cashierWindow,
      icon: Icons.point_of_sale_rounded,
      activeIcon: Icons.point_of_sale_rounded,
      prominent: !cashier,
    );
    final List<AppNavItem> items = cashier
        ? <AppNavItem>[
            till,
            AppNavItem(
              label: s.manualTab,
              icon: Icons.dialpad_rounded,
              activeIcon: Icons.dialpad_rounded,
            ),
          ]
        : <AppNavItem>[
            AppNavItem(
                label: s.tabDashboard,
                icon: AppIcons.dashboard,
                activeIcon: AppIcons.dashboardActive),
            AppNavItem(
                label: s.tabCustomers,
                icon: AppIcons.customers,
                activeIcon: AppIcons.customersActive),
            till,
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
      // Only the first tab's own page may exit the app; sub-pages that
      // fall back to index 0 (e.g. NFC, analytics) return to it instead.
      canPop: GoRouterState.of(context).uri.path == routes[0],
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) return;
        context.go(routes[0]);
      },
      child: AdaptiveNavScaffold(
        items: items,
        currentIndex: currentIdx,
        onSelect: (int i) => context.go(routes[i]),
        // Jumps to the till from any tab when a customer taps "spend".
        child: CounterWatcher(child: child),
      ),
    );
  }
}
