import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/platform/window_attention.dart';
import '../application/panel_providers.dart';
import '../domain/panel_models.dart';

/// Watches the till from every business tab: when a customer taps the
/// venue's "spend" card, the app jumps to the cashier screen (which then
/// opens that customer's window by itself), whatever tab or pushed page the
/// cashier was on. On the desktop till the window is also brought forward.
///
/// Phones only watch while the app is in the foreground (a closed or
/// backgrounded phone app gets a push notification instead); the desktop
/// till keeps watching while minimised, since that is how it usually sits.
class CounterWatcher extends ConsumerStatefulWidget {
  const CounterWatcher({super.key, required this.child});

  final Widget child;

  static const String tillRoute = '/business/scan';

  @override
  ConsumerState<CounterWatcher> createState() => _CounterWatcherState();
}

class _CounterWatcherState extends ConsumerState<CounterWatcher>
    with WidgetsBindingObserver {
  static const Duration _every = Duration(seconds: 3);

  final Set<String> _seen = <String>{};
  Timer? _timer;
  bool _busy = false;
  bool _foreground = true;

  bool get _desktop => !kIsWeb && Platform.isWindows;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(_every, (_) => unawaited(_check()));
    unawaited(_check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) unawaited(_check());
  }

  Future<void> _check() async {
    if (_busy || !mounted) return;
    if (!_foreground && !_desktop) return;
    _busy = true;
    try {
      final List<SpendSession> open =
          await ref.read(panelRepositoryProvider).openSpendSessions();
      if (!mounted) return;
      final List<SpendSession> fresh =
          open.where((SpendSession s) => !_seen.contains(s.id)).toList();
      _seen.addAll(fresh.map((SpendSession s) => s.id));
      if (fresh.isEmpty) return;
      final GoRouter router = GoRouter.of(context);
      final String here = router.routeInformationProvider.value.uri.path;
      if (here != CounterWatcher.tillRoute) router.go(CounterWatcher.tillRoute);
      unawaited(WindowAttention.raise());
    } catch (_) {
      // Offline or signed out: the till screen shows its own error.
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
