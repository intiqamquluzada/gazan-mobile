import 'dart:async';

import 'package:flutter/widgets.dart';

/// Calls [onTick] every [every] while this widget is on screen and the app
/// is in the foreground. Used by business screens so numbers that change
/// when customers tap a card (stamps, gifts, coins) do not go stale.
class PeriodicRefresh extends StatefulWidget {
  const PeriodicRefresh({
    super.key,
    required this.onTick,
    required this.child,
    this.every = const Duration(seconds: 30),
  });

  final VoidCallback onTick;
  final Widget child;
  final Duration every;

  @override
  State<PeriodicRefresh> createState() => _PeriodicRefreshState();
}

class _PeriodicRefreshState extends State<PeriodicRefresh>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(widget.every, (_) {
      if (_foreground && mounted) widget.onTick();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool wasBack = !_foreground && state == AppLifecycleState.resumed;
    _foreground = state == AppLifecycleState.resumed;
    if (wasBack && mounted) widget.onTick(); // coming back: refresh now
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
