import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
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
  AuthController(this._remote, this._tokens) : super(const AuthState()) {
    _restoreSession();
  }

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokens;

  /// On boot, if we have a valid (not expired) access token saved we
  /// rehydrate the session from `/users/me` so the app skips the
  /// auth screens.
  Future<void> _restoreSession() async {
    final String? token = await _tokens.readAccessToken();
    final DateTime? expiresAt = await _tokens.readAccessExpiresAt();
    if (token == null || expiresAt == null || expiresAt.isBefore(DateTime.now())) {
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final AppUser user = await _remote.me();
      state = AuthState(user: user);
    } catch (_) {
      // Token rejected — wipe and let the user sign in again.
      await _tokens.clear();
      state = const AuthState();
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
      state = AuthState(user: session.user);
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
    return 'Xəta baş verdi. Bir azdan yenidən cəhd et.';
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
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
      );
      developer.log('signUp: success user=${session.user.email}',
          name: 'qazan.auth');
      state = AuthState(user: session.user);
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
      await _remote.logout();
    } catch (e, st) {
      developer.log('signOut: remote logout failed (ignored)',
          name: 'qazan.auth', error: e, stackTrace: st);
    } finally {
      state = const AuthState();
    }
  }

  void updateProfile({String? fullName, String? email, String? phone}) {
    final AppUser? user = state.user;
    if (user == null) return;
    state = state.copyWith(
      user: user.copyWith(fullName: fullName, email: email, phone: phone),
    );
  }
}

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (Ref ref) => AuthController(
    ref.read(authRemoteDataSourceProvider),
    ref.read(tokenStorageProvider),
  ),
);

final Provider<AppUser?> currentUserProvider = Provider<AppUser?>(
  (Ref ref) => ref.watch(authControllerProvider).user,
);
