import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/platform/app_variant.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/domain/app_user.dart';
import '../features/auth/domain/user_role.dart';
import '../features/auth/presentation/complete_profile_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/admin/presentation/admin_audit_screen.dart';
import '../features/admin/presentation/admin_businesses_screen.dart';
import '../features/admin/presentation/admin_coins_screen.dart';
import '../features/admin/presentation/admin_company_detail_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/admin_menus_screen.dart';
import '../features/admin/presentation/admin_notifications_screen.dart';
import '../features/admin/presentation/admin_promotions_screen.dart';
import '../features/admin/presentation/admin_shell.dart';
import '../features/admin/presentation/admin_user_detail_screen.dart';
import '../features/admin/presentation/admin_users_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/business/presentation/business_account_screen.dart';
import '../features/business/presentation/business_analytics_screen.dart';
import '../features/business/presentation/business_dashboard_screen.dart';
import '../features/business/presentation/business_manual_screen.dart';
import '../features/business/presentation/business_notify_screen.dart';
import '../features/business/presentation/business_profile_screen.dart';
import '../features/business/presentation/business_staff_screen.dart';
import '../features/business/presentation/customer_detail_screen.dart';
import '../features/business/presentation/customers_list_screen.dart';
import '../features/business/presentation/manage_programs_screen.dart';
import '../features/companies/presentation/companies_screen.dart';
import '../features/companies/presentation/company_detail_screen.dart';
import '../features/companies/presentation/discover_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/home/presentation/business_shell.dart';
import '../features/home/presentation/customer_shell.dart';
import '../features/loyalty/presentation/my_cards_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/promotions/presentation/story_viewer_screen.dart';
import '../features/admin/presentation/admin_reviews_screen.dart';
import '../features/business/presentation/business_menu_screen.dart';
import '../features/business/presentation/business_reviews_screen.dart';
import '../features/nfc/application/nfc_intent_listener.dart';
import '../features/nfc/presentation/nfc_tap_screen.dart';
import '../features/nfc/presentation/spend_waiting_screen.dart';
import '../features/business/presentation/business_nfc_screen.dart';
import '../features/admin/presentation/admin_nfc_screen.dart';
import '../features/business/presentation/business_pending_rewards_screen.dart';
import '../features/wallet/presentation/my_rewards_screen.dart';

/// Root navigator; overlays that must appear on any screen use its context.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _customerShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'customerShell');
final GlobalKey<NavigatorState> _businessShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'businessShell');
final GlobalKey<NavigatorState> _adminShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'adminShell');

/// Bridges Riverpod auth changes into GoRouter. Whenever the user signs
/// in or out, [redirect] is re-evaluated automatically — so logout
/// buttons only need to clear auth state, never navigate by hand.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen<AuthState>(
      authControllerProvider,
      (AuthState? prev, AuthState next) {
        if (prev?.isAuthenticated != next.isAuthenticated ||
            prev?.user?.profileComplete != next.user?.profileComplete) {
          notifyListeners();
        }
      },
    );
  }
}

const Set<String> _publicPaths = <String>{
  '/splash',
  '/onboarding',
  '/login',
  '/register',
  '/forgot-password',
};

/// Where a signed-in user may be. Returns the path to send them to when the
/// location belongs to another role.
String? _guardRole(UserRole role, String location) {
  final bool business =
      location == '/business' || location.startsWith('/business/');
  final bool admin = location == '/admin' || location.startsWith('/admin/');
  final bool shared = location == '/notifications' ||
      location.startsWith('/companies/') ||
      location.startsWith('/stories/');
  switch (role) {
    case UserRole.admin:
      return admin || shared ? null : UserRole.admin.landingPath;
    case UserRole.business:
      return business || shared ? null : UserRole.business.landingPath;
    case UserRole.cashier:
      const Set<String> allowed = <String>{
        '/business/scan',
        '/business/manual',
        '/business/account',
      };
      return allowed.contains(location) ? null : UserRole.cashier.landingPath;
    case UserRole.customer:
      return business || admin ? UserRole.customer.landingPath : null;
  }
}

/// The complete redirect policy; every rule the router applies is here.
String? _redirect(AuthState auth, String location) {
  final bool isPublic = _publicPaths.any(location.startsWith);
  final AppUser? user = auth.user;

  if (user == null) {
    if (AppVariant.isBusinessApp &&
        (location.startsWith('/register') ||
            location.startsWith('/onboarding'))) {
      return '/login';
    }
    return isPublic ? null : '/login';
  }
  if (location == '/splash') return null;

  if (AppVariant.isBusinessApp &&
      user.role != UserRole.business &&
      user.role != UserRole.cashier) {
    return location == '/business-only' ? null : '/business-only';
  }
  // Only customers must supply a phone (Google/Apple sign-up); staff and
  // admin accounts are created without one.
  if (user.role == UserRole.customer && !user.profileComplete) {
    return location == '/complete-profile' ? null : '/complete-profile';
  }
  if (isPublic ||
      location == '/complete-profile' ||
      location == '/business-only') {
    return user.role.landingPath;
  }
  return _guardRole(user.role, location);
}

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final _AuthRefresh authRefresh = _AuthRefresh(ref);
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: authRefresh,
    redirect: (BuildContext context, GoRouterState state) =>
        _redirect(ref.read(authControllerProvider), state.matchedLocation),
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
        path: '/login',
        builder: (BuildContext _, GoRouterState state) => LoginScreen(
          initialIdentifier: state.uri.queryParameters['identifier'],
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext _, GoRouterState state) =>
            RegisterScreen(initialRole: _roleFromQuery(state)),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (BuildContext _, GoRouterState state) => ForgotPasswordScreen(
          initialEmail: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (_, __) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/business-only',
        builder: (_, __) => const BusinessOnlyScreen(),
      ),

      // ───────────────────── Customer shell ─────────────────────
      ShellRoute(
        navigatorKey: _customerShellKey,
        builder: (BuildContext _, GoRouterState __, Widget child) =>
            NfcIntentListener(child: CustomerShell(child: child)),
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (_, __) => const DiscoverScreen(),
          ),
          GoRoute(
            path: '/companies',
            builder: (_, __) => const CompaniesScreen(),
          ),
          GoRoute(
            path: '/cards',
            builder: (_, __) => const MyCardsScreen(),
          ),
          GoRoute(
            path: '/nfc',
            builder: (_, __) => const NfcTapScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Detail pages — pushed on top of the shell.
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/companies/:id',
        builder: (BuildContext _, GoRouterState state) =>
            CompanyDetailScreen(companyId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/stories/:id',
        builder: (BuildContext _, GoRouterState state) =>
            StoryViewerScreen(companyId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/favorites',
        builder: (_, __) => const FavoritesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/rewards',
        builder: (_, __) => const MyRewardsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/spend/:id',
        builder: (BuildContext _, GoRouterState state) =>
            SpendWaitingScreen(sessionId: state.pathParameters['id']!),
      ),
      // Business owner's personal account settings (name/phone, password,
      // language, theme, sign-out). Pushed on top of the business shell.
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/business/account',
        builder: (_, __) => const BusinessAccountScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/business/nfc',
        builder: (_, __) => const BusinessNfcScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/business/menu',
        builder: (_, __) => const BusinessMenuScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/business/reviews',
        builder: (_, __) => const BusinessReviewsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/business/analytics',
        builder: (_, __) => const BusinessAnalyticsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/business/staff',
        builder: (_, __) => const BusinessStaffScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/business/notify',
        builder: (_, __) => const BusinessNotifyScreen(),
      ),
      // Business — rich detail for one customer (contact + purchase log).
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/business/customers/:id',
        builder: (BuildContext _, GoRouterState state) =>
            CustomerDetailScreen(userId: state.pathParameters['id']!),
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
            builder: (_, __) => const BusinessPendingRewardsScreen(),
          ),
          GoRoute(
            path: '/business/manual',
            builder: (_, __) => const BusinessManualScreen(),
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

      // ───────────────────── Admin shell ─────────────────────
      ShellRoute(
        navigatorKey: _adminShellKey,
        builder: (BuildContext _, GoRouterState __, Widget child) =>
            AdminShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (_, __) => const AdminUsersScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: ':id',
                builder: (BuildContext _, GoRouterState state) =>
                    AdminUserDetailScreen(userId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/businesses',
            builder: (_, __) => const AdminBusinessesScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: ':id',
                builder: (BuildContext _, GoRouterState state) =>
                    AdminCompanyDetailScreen(
                        companyId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/coins',
            builder: (_, __) => const AdminCoinsScreen(),
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (_, __) => const AdminNotificationsScreen(),
          ),
          GoRoute(
            path: '/admin/promotions',
            builder: (_, __) => const AdminPromotionsScreen(),
          ),
          GoRoute(
            path: '/admin/menus',
            builder: (_, __) => const AdminMenusScreen(),
          ),
          GoRoute(
            path: '/admin/nfc',
            builder: (_, __) => const AdminNfcScreen(),
          ),
          GoRoute(
            path: '/admin/reviews',
            builder: (_, __) => const AdminReviewsScreen(),
          ),
          GoRoute(
            path: '/admin/audit',
            builder: (_, __) => const AdminAuditScreen(),
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
