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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final AuthSession session = await _remote.login(
        email: email,
        password: password,
      );
      state = AuthState(user: session.user);
    } on ApiException catch (e) {
      state = AuthState(error: e.message);
      rethrow;
    } finally {
      if (state.user == null) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final AuthSession session = await _remote.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
      );
      state = AuthState(user: session.user);
    } on ApiException catch (e) {
      state = AuthState(error: e.message);
      rethrow;
    } finally {
      if (state.user == null) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> signOut() async {
    await _remote.logout();
    state = const AuthState();
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
