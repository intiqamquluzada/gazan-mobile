import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'push_repository.dart';

/// Bridges Firebase Cloud Messaging to the backend so the OS can show real
/// phone notifications (lock screen / notification tray), not just the
/// in-app inbox.
///
/// **Temporarily disabled.** Firebase isn't configured on this build (no
/// `google-services.json` / `GoogleService-Info.plist`), so every method is
/// a silent no-op and the `firebase_core` / `firebase_messaging` packages
/// are removed from `pubspec.yaml`. This keeps the app free of Firebase
/// native code — no connection errors, no crashes — while still leaving the
/// call sites (sign-in / sign-out) intact.
///
/// To switch push back on:
///   1. Re-add `firebase_core` + `firebase_messaging` to `pubspec.yaml`.
///   2. Drop in `google-services.json` (Android) / `GoogleService-Info.plist`
///      (iOS) — see `PUSH_SETUP.md`.
///   3. Restore the FCM init + `getToken()` logic below.
class PushService {
  PushService(this._tokens);

  // Retained so re-enabling push is a one-file change; unused while the
  // service is a no-op.
  // ignore: unused_field
  final PushRepository _tokens;

  /// Call right after sign-in. No-op until Firebase is configured.
  Future<void> syncToken() async {
    // Intentionally does nothing — push is disabled on this build.
  }

  /// Call on sign-out. No-op until Firebase is configured.
  Future<void> clearToken() async {
    // Intentionally does nothing — push is disabled on this build.
  }
}

final Provider<PushService> pushServiceProvider = Provider<PushService>(
  (Ref ref) => PushService(ref.read(pushRepositoryProvider)),
);
