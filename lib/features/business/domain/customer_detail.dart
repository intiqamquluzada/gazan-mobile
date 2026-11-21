/// Rich profile of one customer at this business — feeds the
/// customer-detail screen opened from the dashboard / customers list.
class CustomerDetail {
  const CustomerDetail({
    required this.userId,
    required this.fullName,
    required this.totalStamps,
    required this.totalRewardsClaimed,
    required this.rewardsAvailable,
    required this.totalVisits,
    required this.cardCount,
    required this.cards,
    required this.recentActivity,
    this.coinBalance = 0,
    this.email,
    this.phone,
    this.memberSince,
    this.lastActivityAt,
  });

  final String userId;
  final String fullName;
  final String? email;
  final String? phone;
  final DateTime? memberSince;
  final DateTime? lastActivityAt;
  final int totalStamps;
  final int totalRewardsClaimed;
  final int rewardsAvailable;
  final int totalVisits;
  final int cardCount;
  final List<CustomerCard> cards;
  final List<CustomerActivity> recentActivity;

  /// Coins this customer holds at the venue.
  final int coinBalance;

  factory CustomerDetail.fromJson(Map<String, dynamic> j) {
    return CustomerDetail(
      userId: (j['userId'] as String?) ?? '',
      fullName: (j['fullName'] as String?) ?? '',
      email: j['email'] as String?,
      phone: j['phone'] as String?,
      memberSince: _date(j['memberSince']),
      lastActivityAt: _date(j['lastActivityAt']),
      totalStamps: ((j['totalStamps'] as num?) ?? 0).toInt(),
      totalRewardsClaimed: ((j['totalRewardsClaimed'] as num?) ?? 0).toInt(),
      rewardsAvailable: ((j['rewardsAvailable'] as num?) ?? 0).toInt(),
      totalVisits: ((j['totalVisits'] as num?) ?? 0).toInt(),
      cardCount: ((j['cardCount'] as num?) ?? 0).toInt(),
      coinBalance: ((j['coinBalance'] as num?) ?? 0).toInt(),
      cards: ((j['cards'] as List<dynamic>?) ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(CustomerCard.fromJson)
          .toList(growable: false),
      recentActivity:
          ((j['recentActivity'] as List<dynamic>?) ?? const <dynamic>[])
              .cast<Map<String, dynamic>>()
              .map(CustomerActivity.fromJson)
              .toList(growable: false),
    );
  }
}

class CustomerCard {
  const CustomerCard({
    required this.programTitle,
    required this.stamps,
    required this.stampsRequired,
    required this.rewardsAvailable,
    required this.totalRewardsClaimed,
    this.lastActivityAt,
    this.joinedAt,
  });

  final String programTitle;
  final int stamps;
  final int stampsRequired;
  final int rewardsAvailable;
  final int totalRewardsClaimed;
  final DateTime? lastActivityAt;
  final DateTime? joinedAt;

  double get progress =>
      stampsRequired <= 0 ? 0 : (stamps / stampsRequired).clamp(0.0, 1.0);

  factory CustomerCard.fromJson(Map<String, dynamic> j) {
    return CustomerCard(
      programTitle: (j['programTitle'] as String?) ?? '',
      stamps: ((j['stamps'] as num?) ?? 0).toInt(),
      stampsRequired: ((j['stampsRequired'] as num?) ?? 0).toInt(),
      rewardsAvailable: ((j['rewardsAvailable'] as num?) ?? 0).toInt(),
      totalRewardsClaimed: ((j['totalRewardsClaimed'] as num?) ?? 0).toInt(),
      lastActivityAt: _date(j['lastActivityAt']),
      joinedAt: _date(j['joinedAt']),
    );
  }
}

class CustomerActivity {
  const CustomerActivity({
    required this.type,
    required this.amount,
    required this.programTitle,
    this.note,
    this.at,
  });

  final String type; // STAMP_ADDED, REWARD_CLAIMED
  final int amount;
  final String programTitle;
  final String? note;
  final DateTime? at;

  bool get isReward => type == 'REWARD_CLAIMED';

  factory CustomerActivity.fromJson(Map<String, dynamic> j) {
    return CustomerActivity(
      type: (j['type'] as String?) ?? '',
      amount: ((j['amount'] as num?) ?? 0).toInt(),
      programTitle: (j['programTitle'] as String?) ?? '',
      note: j['note'] as String?,
      at: _date(j['at']),
    );
  }
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw)?.toLocal() : null;
