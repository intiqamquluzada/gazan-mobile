/// A customer's progress on a single LoyaltyProgram.
class LoyaltyCard {
  const LoyaltyCard({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.programId,
    required this.stamps,
    required this.stampsRequired,
    required this.rewardsAvailable,
    required this.lastActivityAt,
    this.totalRewardsClaimed = 0,
  });

  final String id;
  final String userId;
  final String companyId;
  final String programId;

  /// Current stamps toward the next reward (resets when reward earned).
  final int stamps;
  final int stampsRequired;

  /// Earned but not-yet-redeemed rewards.
  final int rewardsAvailable;

  /// Lifetime rewards claimed — useful for "VIP" badges later.
  final int totalRewardsClaimed;

  final DateTime lastActivityAt;

  double get progress =>
      stampsRequired == 0 ? 0 : (stamps / stampsRequired).clamp(0, 1).toDouble();

  int get stampsUntilReward => (stampsRequired - stamps).clamp(0, stampsRequired);

  LoyaltyCard copyWith({
    int? stamps,
    int? rewardsAvailable,
    int? totalRewardsClaimed,
    DateTime? lastActivityAt,
  }) =>
      LoyaltyCard(
        id: id,
        userId: userId,
        companyId: companyId,
        programId: programId,
        stamps: stamps ?? this.stamps,
        stampsRequired: stampsRequired,
        rewardsAvailable: rewardsAvailable ?? this.rewardsAvailable,
        totalRewardsClaimed: totalRewardsClaimed ?? this.totalRewardsClaimed,
        lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      );

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as String,
      userId: json['userId'] as String,
      companyId: json['companyId'] as String,
      programId: json['programId'] as String,
      stamps: (json['stamps'] as num).toInt(),
      stampsRequired: (json['stampsRequired'] as num).toInt(),
      rewardsAvailable: (json['rewardsAvailable'] as num).toInt(),
      totalRewardsClaimed: ((json['totalRewardsClaimed'] as num?) ?? 0).toInt(),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
    );
  }
}
