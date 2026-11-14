import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/push/push_service.dart';
import '../../../core/session/session_events.dart';
import '../../../core/storage/token_storage.dart';
import '../../profile/application/profile_settings_controller.dart';
import '../data/auth_remote_data_source.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';
import 'user_scope.dart';

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error});

  final AppUser? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._remote, this._tokens, this._push, this._ref)
      : super(const AuthState()) {
    _expiredSub = _ref.read(sessionEventsProvider).expired.listen((_) {
      if (state.isAuthenticated) _endLocalSession();
    });
    _restoreSession();
  }

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokens;
  final PushService _push;
  final Ref _ref;
  late final StreamSubscription<void> _expiredSub;

  final Completer<void> _restoreCompleter = Completer<void>();

  /// Completes once the initial session restore settles (whether or not a
  /// session was recovered). The splash awaits this so it can route the
  /// user straight to their shell instead of flashing the auth screens.
  Future<void> get restored => _restoreCompleter.future;

  @override
  void dispose() {
    _expiredSub.cancel();
    super.dispose();
  }

  /// On boot we rehydrate the session so the user (almost) never has to
  /// sign in again. The session survives across days and bad networks: it
  /// ends only when the server rejects the refresh token. If `/users/me`
  /// cannot be reached, the last known profile keeps the user signed in.
  Future<void> _restoreSession() async {
    try {
      final String? access = await _tokens.readAccessToken();
      final String? refresh = await _tokens.readRefreshToken();
      final bool hasAnyToken = (access != null && access.isNotEmpty) ||
          (refresh != null && refresh.isNotEmpty);
      if (!hasAnyToken) return;

      state = state.copyWith(isLoading: true);
      try {
        final AppUser user = await _remote.me();
        state = AuthState(user: user);
        unawaited(_push.syncToken());
      } catch (_) {
        // The refresh interceptor clears the tokens only when they are
        // truly dead, so tokens still being here means a transient failure.
        final String? stillThere = await _tokens.readRefreshToken();
        if (stillThere == null || stillThere.isEmpty) {
          state = const AuthState();
          return;
        }
        final AppUser? cached = await _cachedUser();
        state = AuthState(user: cached);
      }
    } finally {
      if (!_restoreCompleter.isCompleted) _restoreCompleter.complete();
    }
  }

  Future<AppUser?> _cachedUser() async {
    try {
      final String? raw = await _tokens.readUserJson();
      if (raw == null) return null;
      return AuthRemoteDataSource.userFromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// [identifier] is an email or a normalized phone. The account's own role
  /// decides where the user lands.
  Future<void> signIn({
    required String identifier,
    required String password,
  }) =>
      _authenticate(() => _remote.login(
            identifier: identifier,
            password: password,
          ));

  /// Signs in with an identity token from Google or Apple.
  Future<void> signInSocial({
    required String provider,
    required String idToken,
    String? fullName,
  }) =>
      _authenticate(() => _remote.social(
            provider: provider,
            idToken: idToken,
            fullName: fullName,
          ));

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    DateTime? birthDate,
  }) =>
      _authenticate(() => _remote.register(
            email: email,
            password: password,
            fullName: fullName,
            role: role,
            phone: phone,
            birthDate: birthDate,
            locale: _ref.read(languageProvider).toUpperCase(),
          ));

  Future<void> _authenticate(Future<AuthSession> Function() call) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final AuthSession session = await call();
      resetUserScopedProviders(_ref);
      state = AuthState(user: session.user);
      unawaited(_push.syncToken());
    } catch (e, st) {
      developer.log('auth failed',
          name: 'qazan.auth', error: e, stackTrace: st);
      state = AuthState(error: _friendlyMessage(e));
      rethrow;
    }
  }

  /// Turns any thrown error into a short, user-facing message.
  String _friendlyMessage(Object e) {
    if (e is ApiException) return e.message;
    return _ref.read(sProvider).errorTryAgain;
  }

  /// Signs the user out. The remote logout is best-effort — even if the
  /// network call or token storage fails, the local session is *always*
  /// cleared so the app can never get stuck in a half-logged-out state.
  Future<void> signOut() async {
    try {
      await _push.clearToken();
      await _remote.logout();
    } catch (e, st) {
      developer.log('signOut: remote logout failed (ignored)',
          name: 'qazan.auth', error: e, stackTrace: st);
    } finally {
      try {
        await _tokens.clear();
      } catch (_) {}
      _endLocalSession();
    }
  }

  void _endLocalSession() {
    state = const AuthState();
    resetUserScopedProviders(_ref);
  }

  /// Replaces the signed-in user with what the server just returned.
  void applyUser(AppUser user) {
    state = AuthState(user: user);
  }

  void updateProfile(
      {String? fullName, String? email, String? phone, String? avatarUrl}) {
    final AppUser? user = state.user;
    if (user == null) return;
    state = state.copyWith(
      user: user.copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
      ),
    );
  }
}

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (Ref ref) => AuthController(
    ref.read(authRemoteDataSourceProvider),
    ref.read(tokenStorageProvider),
    ref.read(pushServiceProvider),
    ref,
  ),
);

final Provider<AppUser?> currentUserProvider = Provider<AppUser?>(
  (Ref ref) => ref.watch(authControllerProvider).user,
);
