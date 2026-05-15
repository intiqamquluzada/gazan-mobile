import '../../../core/network/api_client.dart';
import '../domain/loyalty_card.dart';
import '../domain/loyalty_program.dart';

/// Read/write source of truth for loyalty programs and cards. Backed by
/// the backend's `/companies/.../programs`, `/loyalty/cards`, `/scans`
/// endpoints.
abstract class LoyaltyRepository {
  Future<List<LoyaltyProgram>> programsForCompany(String companyId);
  Future<LoyaltyProgram?> programById(String programId);

  Future<LoyaltyProgram> createProgram({
    required String companyId,
    required String title,
    required String description,
    required int stampsRequired,
    required LoyaltyRewardType rewardType,
    num? rewardValue,
    String rewardItem = 'məhsul',
  });

  Future<LoyaltyProgram> updateProgram(LoyaltyProgram program);
  Future<void> deleteProgram(String programId);

  Future<List<LoyaltyCard>> cardsForUser(String userId);
  Future<LoyaltyCard> joinProgram({
    required String userId,
    required String programId,
  });
  Future<LoyaltyCard> redeemReward(String cardId);

  /// Business action — scans a customer's QR and adds stamp(s).
  Future<LoyaltyCard> scan({
    required String customerId,
    required String programId,
    int stamps = 1,
    String? note,
  });
}

class RemoteLoyaltyRepository implements LoyaltyRepository {
  RemoteLoyaltyRepository(this._api);

  final ApiClient _api;

  // ───────── programs ─────────

  @override
  Future<List<LoyaltyProgram>> programsForCompany(String companyId) async {
    final List<dynamic> raw = await _api.get<List<dynamic>>(
      '/api/v1/companies/$companyId/programs',
      query: <String, dynamic>{'activeOnly': 'false'},
    );
    return raw
        .cast<Map<String, dynamic>>()
        .map(LoyaltyProgram.fromJson)
        .toList(growable: false);
  }

  @override
  Future<LoyaltyProgram?> programById(String programId) async {
    try {
      final Map<String, dynamic> json =
          await _api.get<Map<String, dynamic>>('/api/v1/programs/$programId');
      return LoyaltyProgram.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<LoyaltyProgram> createProgram({
    required String companyId,
    required String title,
    required String description,
    required int stampsRequired,
    required LoyaltyRewardType rewardType,
    num? rewardValue,
    String rewardItem = 'məhsul',
  }) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/companies/$companyId/programs',
      body: <String, dynamic>{
        'title': title,
        'description': description,
        'stampsRequired': stampsRequired,
        'rewardType': rewardType.wire,
        if (rewardValue != null) 'rewardValue': rewardValue,
        'rewardItem': rewardItem,
      },
    );
    return LoyaltyProgram.fromJson(json);
  }

  @override
  Future<LoyaltyProgram> updateProgram(LoyaltyProgram p) async {
    final Map<String, dynamic> json = await _api.put<Map<String, dynamic>>(
      '/api/v1/programs/${p.id}',
      body: <String, dynamic>{
        'title': p.title,
        'description': p.description,
        'stampsRequired': p.stampsRequired,
        'rewardType': p.rewardType.wire,
        if (p.rewardValue != null) 'rewardValue': p.rewardValue,
        'rewardItem': p.rewardItem,
        'active': p.isActive,
      },
    );
    return LoyaltyProgram.fromJson(json);
  }

  @override
  Future<void> deleteProgram(String programId) =>
      _api.delete('/api/v1/programs/$programId');

  // ───────── cards ─────────

  @override
  Future<List<LoyaltyCard>> cardsForUser(String userId) async {
    final List<dynamic> raw =
        await _api.get<List<dynamic>>('/api/v1/loyalty/cards/me');
    return raw
        .cast<Map<String, dynamic>>()
        .map(LoyaltyCard.fromJson)
        .toList(growable: false);
  }

  @override
  Future<LoyaltyCard> joinProgram({
    required String userId,
    required String programId,
  }) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/loyalty/cards/me',
      body: <String, dynamic>{'programId': programId},
    );
    return LoyaltyCard.fromJson(json);
  }

  @override
  Future<LoyaltyCard> redeemReward(String cardId) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/loyalty/cards/$cardId/redeem',
    );
    return LoyaltyCard.fromJson(json);
  }

  @override
  Future<LoyaltyCard> scan({
    required String customerId,
    required String programId,
    int stamps = 1,
    String? note,
  }) async {
    final Map<String, dynamic> json = await _api.post<Map<String, dynamic>>(
      '/api/v1/scans',
      body: <String, dynamic>{
        'customerId': customerId,
        'programId': programId,
        'stamps': stamps,
        if (note != null) 'note': note,
      },
    );
    return LoyaltyCard.fromJson(json);
  }
}
