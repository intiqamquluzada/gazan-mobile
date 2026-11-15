import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/network/api_client.dart';

/// Localized name of a card kind.
String nfcKindLabel(S s, String kind) => switch (kind) {
      'STAMP' => s.nfcKindStamp,
      'POINTS' => s.nfcKindPoints,
      'SPEND' => s.nfcKindSpend,
      _ => s.nfcKindUnassigned,
    };

/// Localized card status.
String nfcStatusLabel(S s, String status) => switch (status) {
      'ACTIVE' => s.statusActive,
      'LOST' => s.statusLost,
      'REVOKED' => s.statusRevoked,
      _ => s.statusSuspended,
    };

/// Localized reason a tap was refused.
String nfcResultLabel(S s, String result) => switch (result) {
      'OK' => s.statusActive,
      'COOLDOWN' => s.nfcResCooldown,
      'DAILY_CAP' => s.nfcResDailyCap,
      'OUT_OF_RANGE' => s.nfcResOutOfRange,
      'REVOKED' => s.statusRevoked,
      'UNKNOWN_TAG' || 'WRONG_UID' || 'MISSING_UID' => s.nfcResBadCard,
      _ => s.nfcResOther,
    };

/// An NFC card as the admin / business panels see it.
class NfcCard {
  const NfcCard({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.kind,
    required this.status,
    required this.pointsValue,
    required this.stampsValue,
    required this.cooldownSec,
    required this.dailyCapPerUser,
    this.label,
    this.programId,
    this.programTitle,
    this.tagUid,
    this.provisionedAt,
    this.token,
  });

  final String id;
  final String companyId;
  final String companyName;
  final String kind; // UNASSIGNED | STAMP | POINTS | SPEND
  final String status; // ACTIVE | LOST | REVOKED | SUSPENDED
  final String? label;
  final String? programId;
  final String? programTitle;
  final String? tagUid;
  final int pointsValue;
  final int stampsValue;
  final int cooldownSec;
  final int dailyCapPerUser;
  final DateTime? provisionedAt;

  /// Only present right after create / rotate — this is what goes on the tag.
  final String? token;

  bool get isStamp => kind == 'STAMP';
  bool get isAssigned => kind != 'UNASSIGNED';

  /// What this card does, for a list row.
  String describe(S s) => switch (kind) {
        'STAMP' => programTitle ?? s.nfcKindStamp,
        'POINTS' => '$pointsValue ${s.coinLabel}',
        'SPEND' => s.nfcExplainSpend,
        _ => s.nfcNeedsAssign,
      };
  bool get isActive => status == 'ACTIVE';
  bool get isWritten => provisionedAt != null;

  factory NfcCard.fromJson(Map<String, dynamic> j) => NfcCard(
        id: j['id'] as String,
        companyId: (j['companyId'] as String?) ?? '',
        companyName: (j['companyName'] as String?) ?? '',
        kind: (j['kind'] as String?) ?? 'UNASSIGNED',
        status: (j['status'] as String?) ?? 'ACTIVE',
        label: j['label'] as String?,
        programId: j['programId'] as String?,
        programTitle: j['programTitle'] as String?,
        tagUid: j['tagUid'] as String?,
        pointsValue: (j['pointsValue'] as num?)?.toInt() ?? 0,
        stampsValue: (j['stampsValue'] as num?)?.toInt() ?? 1,
        cooldownSec: (j['cooldownSec'] as num?)?.toInt() ?? 0,
        dailyCapPerUser: (j['dailyCapPerUser'] as num?)?.toInt() ?? 0,
        provisionedAt: j['provisionedAt'] == null
            ? null
            : DateTime.tryParse(j['provisionedAt'] as String)?.toLocal(),
        token: j['token'] as String?,
      );
}

/// One line of the tap log.
class NfcTapLog {
  const NfcTapLog({
    required this.id,
    required this.result,
    required this.pointsDelta,
    required this.stampsDelta,
    required this.suspicious,
    this.distanceM,
    this.createdAt,
    this.note,
  });

  final String id;
  final String result;
  final int pointsDelta;
  final int stampsDelta;
  final bool suspicious;
  final int? distanceM;
  final DateTime? createdAt;
  final String? note;

  bool get accepted => result == 'OK';

  factory NfcTapLog.fromJson(Map<String, dynamic> j) => NfcTapLog(
        id: j['id'] as String,
        result: (j['result'] as String?) ?? '',
        pointsDelta: (j['pointsDelta'] as num?)?.toInt() ?? 0,
        stampsDelta: (j['stampsDelta'] as num?)?.toInt() ?? 0,
        suspicious: (j['suspicious'] as bool?) ?? false,
        distanceM: (j['distanceM'] as num?)?.toInt(),
        createdAt: j['createdAt'] == null
            ? null
            : DateTime.tryParse(j['createdAt'] as String)?.toLocal(),
        note: j['note'] as String?,
      );
}

/// Card inventory + tap log. Admin paths manage every venue; business paths
/// are scoped to the caller's own venue by the server.
class NfcAdminRepository {
  NfcAdminRepository(this._api);

  final ApiClient _api;

  Future<List<NfcCard>> adminCards({String? companyId}) async {
    final List<dynamic> raw = await _api.get<List<dynamic>>(
      '/api/v1/admin/nfc/tags',
      query: companyId == null ? null : <String, dynamic>{'companyId': companyId},
    );
    return raw.cast<Map<String, dynamic>>().map(NfcCard.fromJson).toList();
  }

  Future<NfcCard> create({
    required String companyId,
    required String kind,
    String? programId,
    String? label,
    int? pointsValue,
    int? cooldownSec,
    int? dailyCapPerUser,
  }) async {
    final Map<String, dynamic> json =
        await _api.post<Map<String, dynamic>>('/api/v1/admin/nfc/tags',
            body: <String, dynamic>{
          'companyId': companyId,
          'kind': kind,
          'programId': programId,
          'label': label,
          'pointsValue': pointsValue,
          'cooldownSec': cooldownSec,
          'dailyCapPerUser': dailyCapPerUser,
        });
    return NfcCard.fromJson(json);
  }

  /// New secret for a card that was lost or copied — the tag must be rewritten.
  Future<NfcCard> rotate(String id) async {
    final Map<String, dynamic> json = await _api
        .post<Map<String, dynamic>>('/api/v1/admin/nfc/tags/$id/rotate');
    return NfcCard.fromJson(json);
  }

  Future<void> markWritten(String id) =>
      _api.post<dynamic>('/api/v1/admin/nfc/tags/$id/provisioned');

  Future<void> setStatus(String id, String status, {bool asAdmin = true}) =>
      _api.patch<dynamic>(asAdmin
          ? '/api/v1/admin/nfc/tags/$id/status?value=$status'
          : '/api/v1/business/nfc/tags/$id/status?value=$status');

  /// Finds the owner's card from what the phone just read.
  Future<NfcCard> identify({required String token, String? tagUid}) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/business/nfc/identify',
      body: <String, dynamic>{'token': token, 'tagUid': tagUid},
    );
    return NfcCard.fromJson(json);
  }

  /// Sets what one of the owner's cards does.
  Future<void> assign(
    String id, {
    required String kind,
    String? programId,
    int? pointsValue,
    int? stampsValue,
    String? label,
    int? cooldownSec,
    int? dailyCapPerUser,
  }) =>
      _api.patch<dynamic>(
        '/api/v1/business/nfc/tags/$id/assign',
        body: <String, dynamic>{
          'kind': kind,
          'programId': programId,
          'pointsValue': pointsValue,
          'stampsValue': stampsValue,
          'label': label,
          'cooldownSec': cooldownSec,
          'dailyCapPerUser': dailyCapPerUser,
        },
      );

  Future<List<NfcTapLog>> adminTaps({bool suspiciousOnly = false}) async {
    final List<dynamic> raw = await _api.get<List<dynamic>>(
      '/api/v1/admin/nfc/taps',
      query: <String, dynamic>{'suspicious': suspiciousOnly, 'limit': 200},
    );
    return raw.cast<Map<String, dynamic>>().map(NfcTapLog.fromJson).toList();
  }

  Future<List<NfcCard>> myCards() async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/business/nfc/tags');
    return raw.cast<Map<String, dynamic>>().map(NfcCard.fromJson).toList();
  }

  Future<List<NfcTapLog>> myTaps({int days = 7}) async {
    final List<dynamic> raw = await _api.get<List<dynamic>>(
      '/api/v1/business/nfc/taps',
      query: <String, dynamic>{'days': days, 'limit': 200},
    );
    return raw.cast<Map<String, dynamic>>().map(NfcTapLog.fromJson).toList();
  }
}

final Provider<NfcAdminRepository> nfcAdminRepositoryProvider =
    Provider<NfcAdminRepository>(
        (Ref ref) => NfcAdminRepository(ref.read(apiClientProvider)));

final AutoDisposeFutureProvider<List<NfcCard>> myNfcCardsProvider =
    FutureProvider.autoDispose<List<NfcCard>>(
        (Ref ref) => ref.read(nfcAdminRepositoryProvider).myCards());

final AutoDisposeFutureProvider<List<NfcTapLog>> myNfcTapsProvider =
    FutureProvider.autoDispose<List<NfcTapLog>>(
        (Ref ref) => ref.read(nfcAdminRepositoryProvider).myTaps());

final AutoDisposeFutureProvider<List<NfcCard>> adminNfcCardsProvider =
    FutureProvider.autoDispose<List<NfcCard>>(
        (Ref ref) => ref.read(nfcAdminRepositoryProvider).adminCards());
