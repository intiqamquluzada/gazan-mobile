import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/platform/app_variant.dart';
import '../../../routing/app_router.dart';
import 'nfc_tap_flow.dart';

/// Wraps the customer shell. On Android a card touching the phone arrives
/// as an NDEF intent, even with the app closed or on another screen, and
/// `MainActivity` hands it over here. It also retries taps queued offline
/// whenever the app comes back to the foreground.
class NfcIntentListener extends ConsumerStatefulWidget {
  const NfcIntentListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NfcIntentListener> createState() => _NfcIntentListenerState();
}

class _NfcIntentListenerState extends ConsumerState<NfcIntentListener>
    with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel('az.qazan/nfc_intent');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_flushQueue());
    if (PlatformCaps.isAndroid) {
      _channel.setMethodCallHandler((MethodCall call) async {
        if (call.method == 'onTag') _handle(call.arguments);
      });
      unawaited(_takeLaunchTag());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (PlatformCaps.isAndroid) _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_flushQueue());
  }

  Future<void> _takeLaunchTag() async {
    try {
      _handle(await _channel.invokeMethod<Object?>('takeInitial'));
    } on MissingPluginException {
      // Not running on the Android embedding.
    } on PlatformException {
      // Nothing to take.
    }
  }

  void _handle(Object? arguments) {
    if (arguments is! Map) return;
    final Object? token = arguments['token'];
    if (token is! String || token.isEmpty) return;
    final Object? uid = arguments['uid'];
    unawaited(_submit(token, uid is String ? uid : ''));
  }

  Future<void> _submit(String token, String uid) async {
    final S s = ref.read(sProvider);
    final NfcTapFlow flow = ref.read(nfcTapFlowProvider);
    try {
      await flow.submit(token: token, uid: uid);
    } on ApiException catch (e) {
      _toast(e.isNetwork ? s.nfcOfflineQueued : e.message);
    } catch (_) {
      _toast(s.errorTryAgain);
    }
  }

  Future<void> _flushQueue() async {
    final S s = ref.read(sProvider);
    final int sent = await ref.read(nfcTapFlowProvider).flushQueue();
    if (sent > 0) _toast(s.nfcQueuedSent(sent));
  }

  void _toast(String message) {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
