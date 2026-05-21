/// One reward voucher — either a coin-bought ACTIVE one, the same one
/// after it was USED at the cashier, or a virtual entry generated from a
/// completed stamp card. Mirrors backend `RewardClaimResponse`.
class AppRewardClaim {
  const AppRewardClaim({
    required this.kind, // 'COIN' | 'CARD'
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.coinCost,
    required this.status, // 'ACTIVE' | 'USED'
    this.companyLogoUrl,
    this.createdAt,
    this.usedAt,
  });

  final String kind;
  final String id;
  final String companyId;
  final String companyName;
  final String? companyLogoUrl;
  final String title;
  final int coinCost;
  final String status;
  final DateTime? createdAt;
  final DateTime? usedAt;

  bool get isCoin => kind == 'COIN';
  bool get isActive => status == 'ACTIVE';

  factory AppRewardClaim.fromJson(Map<String, dynamic> j) => AppRewardClaim(
        kind: (j['kind'] as String?) ?? 'COIN',
        id: (j['id'] as String?) ?? '',
        companyId: (j['companyId'] as String?) ?? '',
        companyName: (j['companyName'] as String?) ?? '',
        companyLogoUrl: j['companyLogoUrl'] as String?,
        title: (j['title'] as String?) ?? '',
        coinCost: ((j['coinCost'] as num?) ?? 0).toInt(),
        status: (j['status'] as String?) ?? 'ACTIVE',
        createdAt: _date(j['createdAt']),
        usedAt: _date(j['usedAt']),
      );
}

DateTime? _date(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;
