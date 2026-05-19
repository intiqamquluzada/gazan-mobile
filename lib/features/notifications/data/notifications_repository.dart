import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    return AppNotification(
      id: j['id'] as String,
      title: (j['title'] as String?) ?? '',
      body: (j['body'] as String?) ?? '',
      read: (j['read'] as bool?) ?? false,
      createdAt: j['createdAt'] is String
          ? DateTime.tryParse(j['createdAt'] as String)?.toLocal()
          : null,
    );
  }
}

/// Notification inbox + admin broadcast. All endpoints require auth.
class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<List<AppNotification>> inbox() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/notifications');
    return raw
        .cast<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList(growable: false);
  }

  Future<int> unreadCount() async {
    final Map<String, dynamic> j = await _api
        .get<Map<String, dynamic>>('/api/v1/notifications/unread-count');
    return ((j['count'] as num?) ?? 0).toInt();
  }

  Future<void> markAllRead() async {
    await _api.post<dynamic>('/api/v1/notifications/read-all');
  }

  // ── Admin ──
  Future<void> adminSend({
    required String title,
    required String body,
  }) async {
    await _api.post<dynamic>(
      '/api/v1/admin/notifications',
      body: <String, dynamic>{'title': title, 'body': body},
    );
  }

  Future<List<AppNotification>> adminSent() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/admin/notifications');
    return raw
        .cast<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList(growable: false);
  }
}

final Provider<NotificationsRepository> notificationsRepositoryProvider =
    Provider<NotificationsRepository>(
  (Ref ref) => NotificationsRepository(ref.read(apiClientProvider)),
);
