import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

/// One promotion banner as the admin manages it (includes active flag).
class AdminPromotion {
  const AdminPromotion({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientStartHex,
    required this.gradientEndHex,
    required this.cta,
    required this.active,
    required this.sortOrder,
    this.imageUrl,
    this.companyId,
    this.endsAt,
  });

  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final String emoji;
  final int gradientStartHex;
  final int gradientEndHex;
  final String cta;
  final bool active;
  final int sortOrder;
  final String? companyId;
  final DateTime? endsAt;

  /// Optional banner background photo.
  final String? imageUrl;

  factory AdminPromotion.fromJson(Map<String, dynamic> j) {
    return AdminPromotion(
      id: j['id'] as String,
      companyId: j['companyId'] as String?,
      tag: (j['tag'] as String?) ?? '',
      title: (j['title'] as String?) ?? '',
      subtitle: (j['subtitle'] as String?) ?? '',
      emoji: (j['emoji'] as String?) ?? '🎁',
      imageUrl: AppConfig.mediaUrlOrNull(j['imageUrl'] as String?),
      gradientStartHex: (j['gradientStartHex'] as num?)?.toInt() ?? 0xFF9C7556,
      gradientEndHex: (j['gradientEndHex'] as num?)?.toInt() ?? 0xFF7A5439,
      cta: (j['cta'] as String?) ?? 'Bax',
      active: (j['active'] as bool?) ?? true,
      sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
      endsAt: j['endsAt'] is String
          ? DateTime.tryParse(j['endsAt'] as String)
          : null,
    );
  }
}

class AdminPromotionsRepository {
  AdminPromotionsRepository(this._api);

  final ApiClient _api;

  Future<List<AdminPromotion>> list() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/admin/promotions');
    return raw
        .cast<Map<String, dynamic>>()
        .map(AdminPromotion.fromJson)
        .toList(growable: false);
  }

  Future<void> create({
    required String tag,
    required String title,
    String? subtitle,
    String? emoji,
    String? cta,
    int gradientStartHex = 0xFF9C7556,
    int gradientEndHex = 0xFF7A5439,
    bool active = true,
    int sortOrder = 0,
    String? imageUrl,
    String? companyId,
    DateTime? endsAt,
  }) async {
    await _api.post<dynamic>(
      '/api/v1/admin/promotions',
      body: <String, dynamic>{
        'tag': tag,
        'title': title,
        'subtitle': subtitle,
        'emoji': emoji,
        'cta': cta,
        'gradientStartHex': gradientStartHex,
        'gradientEndHex': gradientEndHex,
        'active': active,
        'sortOrder': sortOrder,
        if (imageUrl != null && imageUrl.isNotEmpty)
          'imageUrl': AppConfig.storedMediaUrl(imageUrl),
        if (companyId != null) 'companyId': companyId,
        if (endsAt != null) 'endsAt': endsAt.toUtc().toIso8601String(),
      },
    );
  }

  Future<void> update(String id, Map<String, dynamic> patch) async {
    final Object? image = patch['imageUrl'];
    if (image is String) patch['imageUrl'] = AppConfig.storedMediaUrl(image);
    await _api.put<dynamic>('/api/v1/admin/promotions/$id', body: patch);
  }

  Future<void> setActive(String id, bool active) async {
    await _api.patch<dynamic>(
      '/api/v1/admin/promotions/$id/active?active=$active',
    );
  }

  Future<void> delete(String id) async {
    await _api.delete('/api/v1/admin/promotions/$id');
  }
}

final Provider<AdminPromotionsRepository> adminPromotionsRepositoryProvider =
    Provider<AdminPromotionsRepository>(
  (Ref ref) => AdminPromotionsRepository(ref.read(apiClientProvider)),
);

final FutureProvider<List<AdminPromotion>> adminPromotionsProvider =
    FutureProvider<List<AdminPromotion>>(
  (Ref ref) => ref.read(adminPromotionsRepositoryProvider).list(),
);
