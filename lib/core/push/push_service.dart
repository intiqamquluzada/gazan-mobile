import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'push_repository.dart';

/// Android channel used for every Qazan notification. The backend names the
/// same id in its FCM payload, so keep the two in sync.
const String kPushChannelId = 'qazan_default';

/// Firebase settings can come from `--dart-define`s (no files needed) or,
/// when those are absent, from `google-services.json` /
/// `GoogleService-Info.plist` picked up by the native SDKs.
FirebaseOptions? _optionsFromDefines() {
  const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  const String senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  if (apiKey.isEmpty || appId.isEmpty || senderId.isEmpty || projectId.isEmpty) {
    return null;
  }
  return const FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: senderId,
    projectId: projectId,
    iosBundleId: 'az.qazan.app',
  );
}

/// Push problems are device-specific and hard to reproduce, so these lines
/// stay visible in release builds (`adb logcat -s flutter`). They never
/// contain the token itself.
void _log(String msg) {
  // ignore: avoid_print
  print('qazan.push: $msg');
}

bool get _pushPlatform => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// Runs in a background isolate when a message arrives while the app is not
/// in the foreground. The OS already shows notification messages itself, so
/// this only has to exist (FCM requires a registered handler).
@pragma('vm:entry-point')
Future<void> qazanBackgroundMessage(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: _optionsFromDefines());
    }
  } catch (_) {/* not configured: nothing to do */}
}

/// Phone notifications through Firebase Cloud Messaging.
///
/// Fully optional: when Firebase is not configured (no defines, no config
/// file) or the platform has no FCM (web, Windows), every call is a quiet
/// no-op and the in-app inbox keeps working.
///
///  * [init] once at start-up (before `runApp`).
///  * [syncToken] after sign-in / session restore: asks for permission,
///    registers this device with the backend, follows token refreshes.
///  * [clearToken] on sign-out so the next account on this phone does not
///    receive the previous one's notifications.
///  * Tapping a notification calls [onOpenRoute] with the `route` the
///    backend put in the payload (e.g. `/notifications`).
class PushService {
  PushService(this._tokens);

  final PushRepository _tokens;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _ready = false;
  /// True while someone is signed in; foreground resumes then re-sync.
  bool _signedIn = false;
  // Kept so the listener lives as long as the service.
  // ignore: unused_field
  AppLifecycleListener? _lifecycle;
  String? _registered;
  StreamSubscription<String>? _refreshSub;

  /// Set by the app once the router exists.
  void Function(String route)? onOpenRoute;

  /// Set by the app: a notification usually means balances, cards or gifts
  /// changed on the server (stamp given, gift used...), so reload them.
  void Function()? onDataChanged;
  String? _pendingRoute;

  bool get isAvailable => _ready;

  Future<void> init() async {
    if (_ready || !_pushPlatform) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: _optionsFromDefines());
      }
    } catch (e) {
      _log('Firebase not configured, push off ($e)');
      return;
    }
    try {
      FirebaseMessaging.onBackgroundMessage(qazanBackgroundMessage);

      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse r) =>
            _open(r.payload),
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            kPushChannelId,
            'Qazan',
            description: 'Hədiyyələr, möhürlər və kampaniyalar',
            importance: Importance.high,
          ));
      // iOS shows banners for foreground messages itself with this on.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              alert: true, badge: true, sound: true);

      FirebaseMessaging.onMessage.listen((RemoteMessage m) {
        onDataChanged?.call();
        // "Customer at the till" opens the cashier screen right away when
        // the app is already open; everything else is just shown.
        if (m.data['autoOpen'] == '1') _open(m.data['route'] as String?);
        unawaited(_showForeground(m));
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
        onDataChanged?.call();
        _open(m.data['route'] as String?);
      });
      final RemoteMessage? initial =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _open(initial.data['route'] as String?);

      _ready = true;
      _lifecycle = AppLifecycleListener(onResume: () {
        if (_signedIn && _registered == null) unawaited(syncToken());
      });
      _log('ready');
    } catch (e) {
      _log('init failed, push off ($e)');
    }
  }

  /// Android does not draw a banner for messages that arrive while the app
  /// is open, so draw one ourselves (iOS handles this natively).
  Future<void> _showForeground(RemoteMessage m) async {
    if (!Platform.isAndroid) return;
    final RemoteNotification? n = m.notification;
    if (n == null) return;
    try {
      await _local.show(
        id: m.hashCode & 0x7fffffff,
        title: n.title,
        body: n.body,
        payload: m.data['route'] as String?,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            kPushChannelId,
            'Qazan',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      _log('foreground show failed ($e)');
    }
  }

  void _open(String? route) {
    if (route == null || route.isEmpty || !route.startsWith('/')) return;
    final void Function(String)? go = onOpenRoute;
    if (go == null) {
      _pendingRoute = route; // router not ready yet (cold start)
    } else {
      go(route);
    }
  }

  /// Called by the app once navigation is possible.
  void attachRouter(void Function(String route) go) {
    onOpenRoute = go;
    final String? pending = _pendingRoute;
    _pendingRoute = null;
    if (pending != null) go(pending);
  }

  bool _syncing = false;

  /// Call right after sign-in or session restore, and again whenever the
  /// app comes back to the foreground (cheap when already registered).
  ///
  /// Google Play services can be unready for a while after the phone
  /// boots, in which case Firebase gives up on the first token request;
  /// so a missing token is retried a few times with growing pauses.
  Future<void> syncToken() async {
    if (!_ready) return;
    _signedIn = true;
    if (_syncing) return;
    _syncing = true;
    try {
      await _cleanup;
      if (!_signedIn) return;
      final NotificationSettings s =
          await FirebaseMessaging.instance.requestPermission();
      _log('permission ${s.authorizationStatus.name}');
      if (s.authorizationStatus == AuthorizationStatus.denied) return;
      if (Platform.isIOS) {
        // No APNs token yet means the build has no push entitlement.
        final String? apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns == null) {
          _log('no APNs token (push entitlement missing?)');
          return;
        }
      }
      String? token;
      for (int attempt = 1; attempt <= 4 && token == null; attempt++) {
        try {
          token = await FirebaseMessaging.instance
              .getToken()
              .timeout(const Duration(seconds: 20));
        } catch (e) {
          _log('getToken attempt $attempt failed ($e)');
        }
        if (token == null && attempt < 4) {
          await Future<void>.delayed(Duration(seconds: 5 * attempt));
        }
      }
      if (token == null) {
        _log('no token; will retry on next foreground');
        return;
      }
      if (token != _registered) {
        await _register(token);
        _log('device registered with backend');
      }
      await _refreshSub?.cancel();
      _refreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(_register);
    } catch (e) {
      _log('token sync failed ($e)');
    } finally {
      _syncing = false;
    }
  }

  Future<void> _register(String token) async {
    await _tokens.register(token, Platform.isIOS ? 'IOS' : 'ANDROID');
    _registered = token;
  }

  /// Forgets this device's registration locally (session ended, maybe
  /// without a reachable server), so the next sign-in registers again.
  void forgetLocal() {
    _registered = null;
    _signedIn = false;
  }

  /// Sign-out clean-up still running in the background; the next sign-in
  /// waits for it so deleting the old token can't kill the new one.
  Future<void>? _cleanup;

  /// Call on sign-out. Stops pushes for this account right away and finishes
  /// the network part (unregister, fresh FCM token) in the background, using
  /// the signed-out session's [accessToken].
  void clearToken({String? accessToken}) {
    _signedIn = false;
    if (!_ready) return;
    final StreamSubscription<String>? sub = _refreshSub;
    _refreshSub = null;
    final String? token = _registered;
    _registered = null;
    final Future<void>? previous = _cleanup;
    late final Future<void> job;
    job = () async {
      await previous;
      await sub?.cancel();
      try {
        if (token != null) {
          await _tokens
              .unregister(token, accessToken: accessToken)
              .timeout(const Duration(seconds: 15));
        }
      } catch (_) {/* best effort */}
      try {
        // A fresh token for the next account on this phone.
        await FirebaseMessaging.instance
            .deleteToken()
            .timeout(const Duration(seconds: 15));
      } catch (_) {}
    }()
        .whenComplete(() {
      if (identical(_cleanup, job)) _cleanup = null;
    });
    _cleanup = job;
  }
}

final Provider<PushService> pushServiceProvider = Provider<PushService>(
  (Ref ref) => PushService(ref.read(pushRepositoryProvider)),
);
