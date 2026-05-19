import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/domain/user_role.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/role_picker_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/business/presentation/business_dashboard_screen.dart';
import '../features/business/presentation/business_profile_screen.dart';
import '../features/business/presentation/customers_list_screen.dart';
import '../features/business/presentation/manage_programs_screen.dart';
import '../features/campaigns/presentation/campaigns_screen.dart';
import '../features/companies/presentation/company_detail_screen.dart';
import '../features/companies/presentation/discover_screen.dart';
import '../features/home/presentation/business_shell.dart';
import '../features/home/presentation/customer_shell.dart';
import '../features/loyalty/presentation/my_cards_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/wallet/presentation/wallet_screen.dart';
import '../features/promotions/presentation/story_viewer_screen.dart';
import '../features/qr/presentation/qr_display_screen.dart';
import '../features/qr/presentation/qr_scanner_screen.dart';

final GlobalKey<NavigatorState> _rootKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _customerShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'customerShell');
final GlobalKey<NavigatorState> _businessShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'businessShell');

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState auth = ref.read(authControllerProvider);
      final String location = state.matchedLocation;

      const Set<String> publicPaths = <String>{
        '/splash', '/onboarding', '/role', '/login', '/register',
      };
      final bool isPublic =
          publicPaths.any((String p) => location.startsWith(p));

      if (!auth.isAuthenticated && !isPublic) return '/role';
      if (auth.isAuthenticated && isPublic && location != '/splash') {
        return auth.user!.role == UserRole.business ? '/business' : '/home';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/role',
        builder: (_, __) => const RolePickerScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext _, GoRouterState state) {
          final UserRole role = _roleFromQuery(state);
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext _, GoRouterState state) {
          final UserRole role = _roleFromQuery(state);
          return RegisterScreen(role: role);
        },
      ),

      // ───────────────────── Customer shell ─────────────────────
      ShellRoute(
        navigatorKey: _customerShellKey,
        builder: (BuildContext _, GoRouterState __, Widget child) =>
            CustomerShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) => const DiscoverScreen(),
            routes: <RouteBase>[],
          ),
          GoRoute(
            path: '/wallet',
            builder: (_, __) => const WalletScreen(),
          ),
          GoRoute(
            path: '/cards',
            builder: (_, __) => const MyCardsScreen(),
          ),
          GoRoute(
            path: '/qr',
            builder: (_, __) => const QrDisplayScreen(),
          ),
          GoRoute(
            path: '/campaigns',
            builder: (_, __) => const CampaignsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Detail pages — pushed on top of the shell.
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/companies/:id',
        builder: (BuildContext _, GoRouterState state) =>
            CompanyDetailScreen(companyId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/stories/:id',
        builder: (BuildContext _, GoRouterState state) =>
            StoryViewerScreen(companyId: state.pathParameters['id']!),
      ),

      // ───────────────────── Business shell ─────────────────────
      ShellRoute(
        navigatorKey: _businessShellKey,
        builder: (BuildContext _, GoRouterState __, Widget child) =>
            BusinessShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/business',
            builder: (_, __) => const BusinessDashboardScreen(),
          ),
          GoRoute(
            path: '/business/scan',
            builder: (_, __) => const QrScannerScreen(),
          ),
          GoRoute(
            path: '/business/customers',
            builder: (_, __) => const CustomersListScreen(),
          ),
          GoRoute(
            path: '/business/programs',
            builder: (_, __) => const ManageProgramsScreen(),
          ),
          GoRoute(
            path: '/business/profile',
            builder: (_, __) => const BusinessProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

UserRole _roleFromQuery(GoRouterState state) {
  final String? r = state.uri.queryParameters['role'];
  return r == 'business' ? UserRole.business : UserRole.customer;
}
