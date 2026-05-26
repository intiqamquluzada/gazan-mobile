import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../profile/application/profile_settings_controller.dart';
import '../data/notifications_repository.dart';

final FutureProvider<List<AppNotification>> notificationInboxProvider =
    FutureProvider<List<AppNotification>>((Ref ref) async {
  ref.watch(languageProvider);
  if (ref.watch(currentUserProvider) == null) return <AppNotification>[];
  return ref.read(notificationsRepositoryProvider).inbox();
});

/// Drives the unread badge on the notification bell.
final FutureProvider<int> unreadCountProvider =
    FutureProvider<int>((Ref ref) async {
  if (ref.watch(currentUserProvider) == null) return 0;
  return ref.read(notificationsRepositoryProvider).unreadCount();
});

final FutureProvider<List<AppNotification>> adminSentProvider =
    FutureProvider<List<AppNotification>>((Ref ref) async {
  ref.watch(languageProvider);
  return ref.read(notificationsRepositoryProvider).adminSent();
});
