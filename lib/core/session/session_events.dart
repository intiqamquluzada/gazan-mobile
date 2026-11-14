import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the network layer tell the auth layer that the session is really
/// over (the refresh token was rejected) without importing it.
class SessionEvents {
  final StreamController<void> _expired = StreamController<void>.broadcast();

  Stream<void> get expired => _expired.stream;

  void notifyExpired() => _expired.add(null);
}

final Provider<SessionEvents> sessionEventsProvider =
    Provider<SessionEvents>((Ref ref) => SessionEvents());
