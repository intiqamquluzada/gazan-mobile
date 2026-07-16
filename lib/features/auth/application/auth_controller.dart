import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/push/push_service.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_remote_data_source.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';

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
    _restoreSession();
  }

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokens;
  final PushService _push;
  final Ref _ref;

  final Completer<void> _restoreCompleter = Completer<void>();

  /// Completes once the initial session restore settles (whether or not a
  /// session was recovered). The splash awaits this so it can route the
  /// user straight to their shell instead of flashing the auth screens.
  Future<void> get restored => _restoreCompleter.future;

  /// On boot we rehydrate the session so the user (almost) never has to
  /// sign in again. As long as *either* token is present we call
  /// `/users/me`:
  ///   * a still-valid access token authenticates the call directly;
  ///   * an expired one triggers a 401 → the [RefreshInterceptor]
  ///     transparently swaps in a fresh token via the refresh token and
  ///     retries.
  /// So the session survives across days/weeks — it only ends when the
  /// refresh token itself is dead (expired or revoked by logout).
  Future<void> _restoreSession() async {
    try {
      final String? access = await _tokens.readAccessToken();
      final String? refresh = await _tokens.readRefreshToken();
      final bool hasAnyToken =
          (access != null && access.isNotEmpty) ||
              (refresh != null && refresh.isNotEmpty);
      if (!hasAnyToken) return;

      state = state.copyWith(isLoading: true);
      try {
        final AppUser user = await _remote.me();
        state = AuthState(user: user);
        unawaited(_push.syncToken());
      } catch (_) {
        // Both tokens rejected — wipe and let the user sign in again.
        await _tokens.clear();
        state = const AuthState();
      }
    } finally {
      if (!_restoreCompleter.isCompleted) _restoreCompleter.complete();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    developer.log('signIn: start  email=$email', name: 'qazan.auth');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      developer.log('signIn: calling _remote.login', name: 'qazan.auth');
      final AuthSession session = await _remote.login(
        email: email,
        password: password,
      );
      developer.log('signIn: got session user=${session.user.email}',
          name: 'qazan.auth');

      // Role-entrance guard: a business owner must sign in from the
      // business entrance and a customer from the customer entrance.
      // Admins are exempt — they can sign in from any entrance.
      final UserRole actual = session.user.role;
      if (actual != UserRole.admin && actual != role) {
        // Undo the login on the server side and surface a clear message.
        try {
          await _remote.logout();
        } catch (_) {/* best-effort */}
        final S s = _ref.read(sProvider);
        final String msg = role == UserRole.business
            ? s.roleMismatchBusiness
            : s.roleMismatchCustomer;
        state = AuthState(error: msg);
        throw ApiException(code: 'ROLE_MISMATCH', message: msg, status: 403);
      }

      state = AuthState(user: session.user);
      unawaited(_push.syncToken());
      developer.log('signIn: state updated', name: 'qazan.auth');
    } catch (e, st) {
      developer.log('signIn: FAILED type=${e.runtimeType}',
          name: 'qazan.auth', error: e, stackTrace: st);
      state = AuthState(error: _friendlyMessage(e));
      rethrow;
    } finally {
      if (state.user == null) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Turns any thrown error into a short, user-facing message.
  String _friendlyMessage(Object e) {
    if (e is ApiException) return e.message;
    return _ref.read(sProvider).errorTryAgain;
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    DateTime? birthDate,
  }) async {
    developer.log('signUp: start  email=$email', name: 'qazan.auth');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final AuthSession session = await _remote.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        birthDate: birthDate,
      );
      developer.log('signUp: success user=${session.user.email}',
          name: 'qazan.auth');
      state = AuthState(user: session.user);
      unawaited(_push.syncToken());
    } catch (e, st) {
      developer.log('signUp: failed', name: 'qazan.auth', error: e, stackTrace: st);
      state = AuthState(error: _friendlyMessage(e));
      rethrow;
    } finally {
      if (state.user == null) {
        state = state.copyWith(isLoading: false);
      }
    }
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
      state = const AuthState();
    }
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
