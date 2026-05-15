/// Per-customer summary as seen by a business owner.
class CustomerSummary {
  const CustomerSummary({
    required this.userId,
    required this.fullName,
    required this.totalVisits,
    required this.totalStamps,
    required this.rewardsClaimed,
    required this.lastVisitAt,
    this.avatarUrl,
    this.phone,
  });

  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? phone;
  final int totalVisits;
  final int totalStamps;
  final int rewardsClaimed;
  final DateTime lastVisitAt;
}
