import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'push_repository.dart';

/// Bridges Firebase Cloud Messaging to the backend so the OS can show real
/// phone notifications (lock screen / notification tray), not just the
/// in-app inbox.
///
/// Entirely optional and fail-safe: if Firebase isn't configured on this
/// build (no `google-services.json` / `GoogleService-Info.plist`, or web
/// without a VAPID key) every method becomes a silent no-op, so the rest of
/// the app is unaffected. See `PUSH_SETUP.md` to switch it on.
class PushService {
  PushService(this._tokens);

  final PushRepository _tokens;

  bool _ready = false;
  FirebaseMessaging? _fm;

  Future<void> _init() async {
    if (_ready) return;
    try {
      await Firebase.initializeApp();
      _fm = FirebaseMessaging.instance;
      await _fm!.requestPermission(); // iOS/web prompt; no-op on Android <13
      _ready = true;
    } catch (_) {
      // Firebase not configured for this platform/build — push stays off.
      _ready = false;
    }
  }

  String get _platform {
    if (kIsWeb) return 'WEB';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'IOS';
      default:
        return 'ANDROID';
    }
  }

  /// Call right after sign-in: fetch the device token and register it so the
  /// backend can target this device. Re-registers automatically on rotation.
  Future<void> syncToken() async {
    await _init();
    if (!_ready || _fm == null) return;
    try {
      final String? token = await _fm!.getToken();
      if (token == null || token.isEmpty) return;
      await _tokens.register(token, _platform);
      _fm!.onTokenRefresh.listen((String t) {
        _tokens.register(t, _platform);
      });
    } catch (_) {
      // No token (e.g. web without VAPID key) — push simply stays off.
    }
  }

  /// Call on sign-out so this device stops receiving the account's pushes.
  Future<void> clearToken() async {
    if (!_ready || _fm == null) return;
    try {
      final String? token = await _fm!.getToken();
      if (token != null && token.isNotEmpty) {
        await _tokens.unregister(token);
      }
      await _fm!.deleteToken();
    } catch (_) {
      // Best-effort — sign-out must never block on push cleanup.
    }
  }
}

final Provider<PushService> pushServiceProvider = Provider<PushService>(
  (Ref ref) => PushService(ref.read(pushRepositoryProvider)),
);
