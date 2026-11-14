import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// Result of a successful tap, as the server computed it.
class NfcTapResult {
  const NfcTapResult({
    required this.kind,
    required this.companyName,
    this.companyId,
    this.programTitle,
    this.stampsAdded = 0,
    this.stampsNow,
    this.stampsRequired,
    this.pointsAdded = 0,
    this.pointsBalance = 0,
    this.rewardUnlocked = false,
    this.unlockedRewardTitle,
    this.spendSessionId,
  });

  final String kind; // STAMP | POINTS | SPEND
  final String? companyId;
  final String companyName;
  final String? programTitle;
  final int stampsAdded;
  final int? stampsNow;
  final int? stampsRequired;
  final int pointsAdded;

  /// The customer's coins at THIS venue after the tap (coins are per venue).
  final int pointsBalance;
  final bool rewardUnlocked;

  /// What the gift unlocked by this tap is, e.g. "Free coffee" (stamp cards).
  final String? unlockedRewardTitle;

  /// The cashier window this tap opened (SPEND cards).
  final String? spendSessionId;

  bool get isStamp => kind == 'STAMP';
  bool get isSpend => kind == 'SPEND';

  factory NfcTapResult.fromJson(Map<String, dynamic> j) => NfcTapResult(
        kind: (j['kind'] as String?) ?? 'POINTS',
        companyId: j['companyId'] as String?,
        companyName: (j['companyName'] as String?) ?? '',
        programTitle: j['programTitle'] as String?,
        stampsAdded: (j['stampsAdded'] as num?)?.toInt() ?? 0,
        stampsNow: (j['stampsNow'] as num?)?.toInt(),
        stampsRequired: (j['stampsRequired'] as num?)?.toInt(),
        pointsAdded: (j['pointsAdded'] as num?)?.toInt() ?? 0,
        pointsBalance: (j['pointsBalance'] as num?)?.toInt() ?? 0,
        rewardUnlocked: (j['rewardUnlocked'] as bool?) ?? false,
        unlockedRewardTitle: j['unlockedRewardTitle'] as String?,
        spendSessionId: j['spendSessionId'] as String?,
      );
}

/// The customer's view of an open cashier window.
class SpendStatus {
  const SpendStatus({
    required this.id,
    required this.status,
    required this.companyName,
    required this.rewards,
    required this.usedTitles,
  });

  final String id;
  final String status; // OPEN | COMPLETED | CANCELLED | EXPIRED
  final String companyName;
  final List<String> rewards;
  final List<String> usedTitles;

  bool get isOpen => status == 'OPEN';
  bool get isExpired => status == 'EXPIRED';

  factory SpendStatus.fromJson(Map<String, dynamic> j) => SpendStatus(
        id: j['id'] as String,
        status: (j['status'] as String?) ?? 'OPEN',
        companyName: (j['companyName'] as String?) ?? '',
        rewards: ((j['rewards'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic r) =>
                r is Map ? (r['title'] as String? ?? '') : '$r')
            .toList(growable: false),
        usedTitles: ((j['usedTitles'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic t) => '$t')
            .toList(growable: false),
      );
}

/// Posts taps to the server and keeps the ones that failed offline.
///
/// Each tap carries a `clientTapId`; the server treats a repeat of the same
/// id as the same tap, so retrying a queued tap can never pay twice.
class NfcRepository {
  NfcRepository(this._api);

  final ApiClient _api;
  static const String _queueKey = 'qazan.nfc_queue';
  static const String _queuedAtKey = '_queuedAt';
  static const Uuid _uuid = Uuid();

  Future<NfcTapResult> tap({
    required String token,
    String? tagUid,
    String? deviceId,
    double? latitude,
    double? longitude,
    String? clientTapId,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'token': token,
      'tagUid': tagUid,
      'deviceId': deviceId,
      'latitude': latitude,
      'longitude': longitude,
      'clientTapId': clientTapId ?? _uuid.v4(),
      // A live tap; queued ones get their real age when they are flushed.
      'ageSeconds': 0,
    };
    try {
      final Map<String, dynamic> json =
          await _api.post<Map<String, dynamic>>('/api/v1/nfc/tap', body: body);
      return NfcTapResult.fromJson(json);
    } on Object catch (e) {
      // Network-ish failure → keep it; a rejection by the server must NOT be
      // queued (it would just be rejected again).
      if (_looksOffline(e)) {
        await _enqueue(body);
      }
      rethrow;
    }
  }

  Future<SpendStatus> spendStatus(String id) async {
    final Map<String, dynamic> json =
        await _api.get<Map<String, dynamic>>('/api/v1/nfc/spend-sessions/$id');
    return SpendStatus.fromJson(json);
  }

  bool _looksOffline(Object e) => e is ApiException && e.isNetwork;

  Future<void> _enqueue(Map<String, dynamic> body) async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      final List<String> q = p.getStringList(_queueKey) ?? <String>[];
      // Remember when the card was actually touched: the server refuses a
      // late "spend" tap, since the customer has probably left the till.
      q.add(jsonEncode(<String, dynamic>{
        ...body,
        _queuedAtKey: DateTime.now().millisecondsSinceEpoch,
      }));
      // Keep the newest taps if the queue ever overflows.
      await p.setStringList(
          _queueKey, q.length > 50 ? q.sublist(q.length - 50) : q);
    } catch (_) {}
  }

  /// Sends everything that was queued while offline. Returns how many taps
  /// were finally accepted (used for the "+N while you were offline" note).
  Future<List<NfcTapResult>> flushQueue() async {
    final List<NfcTapResult> done = <NfcTapResult>[];
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      final List<String> q = p.getStringList(_queueKey) ?? <String>[];
      if (q.isEmpty) return done;
      final List<String> left = <String>[];
      for (final String raw in q) {
        try {
          final Map<String, dynamic> body =
              jsonDecode(raw) as Map<String, dynamic>;
          final int? queuedAt = (body.remove(_queuedAtKey) as num?)?.toInt();
          body['ageSeconds'] = queuedAt == null
              ? null
              : DateTime.now()
                  .difference(DateTime.fromMillisecondsSinceEpoch(queuedAt))
                  .inSeconds;
          final Map<String, dynamic> json = await _api
              .post<Map<String, dynamic>>('/api/v1/nfc/tap', body: body);
          done.add(NfcTapResult.fromJson(json));
        } on Object catch (e) {
          // Still offline → keep for later. Rejected by the server → drop it.
          if (_looksOffline(e)) left.add(raw);
        }
      }
      await p.setStringList(_queueKey, left);
    } catch (_) {}
    return done;
  }

  Future<int> pendingCount() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      return (p.getStringList(_queueKey) ?? <String>[]).length;
    } catch (_) {
      return 0;
    }
  }
}

final Provider<NfcRepository> nfcRepositoryProvider = Provider<NfcRepository>(
  (Ref ref) => NfcRepository(ref.read(apiClientProvider)),
);
