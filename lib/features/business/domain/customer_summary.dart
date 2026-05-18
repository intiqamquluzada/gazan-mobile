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
  /// No per-visit log yet — the card count is a good proxy.
  final int totalVisits;
  final int totalStamps;
  final int rewardsClaimed;
  final DateTime lastVisitAt;

  factory CustomerSummary.fromJson(Map<String, dynamic> json) {
    return CustomerSummary(
      userId: (json['userId'] as String?) ?? '',
      fullName: (json['fullName'] as String?) ?? 'Müştəri',
      phone: json['phone'] as String?,
      totalVisits: ((json['cardCount'] as num?) ?? 0).toInt(),
      totalStamps: ((json['totalStamps'] as num?) ?? 0).toInt(),
      rewardsClaimed: ((json['rewardsClaimed'] as num?) ?? 0).toInt(),
      lastVisitAt: DateTime.tryParse(
            (json['lastActivityAt'] as String?) ?? '',
          )?.toLocal() ??
          DateTime.now(),
    );
  }
}
