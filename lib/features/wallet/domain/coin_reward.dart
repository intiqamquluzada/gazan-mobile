/// A reward the business lets customers claim with coins
/// (e.g. "100 coin → 1 portion San Sebastian"). Mirrors backend
/// `CoinRewardResponse`.
class CoinReward {
  const CoinReward({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.coinCost,
    required this.active,
  });

  final String id;
  final String companyId;
  final String title;
  final String? description;
  final int coinCost;
  final bool active;

  factory CoinReward.fromJson(Map<String, dynamic> json) => CoinReward(
        id: (json['id'] as String?) ?? '',
        companyId: (json['companyId'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        description: json['description'] as String?,
        coinCost: ((json['coinCost'] as num?) ?? 0).toInt(),
        active: (json['active'] as bool?) ?? true,
      );
}

/// One entry in the platform-wide wallet reward catalog. Mirrors backend
/// `CoinRewardCatalogResponse` (carries the owning business).
class CoinRewardCatalogItem {
  const CoinRewardCatalogItem({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.coinCost,
    this.companyLogoUrl,
    this.description,
  });

  final String id;
  final String companyId;
  final String companyName;
  final String? companyLogoUrl;
  final String title;
  final String? description;
  final int coinCost;

  factory CoinRewardCatalogItem.fromJson(Map<String, dynamic> json) =>
      CoinRewardCatalogItem(
        id: (json['id'] as String?) ?? '',
        companyId: (json['companyId'] as String?) ?? '',
        companyName: (json['companyName'] as String?) ?? '',
        companyLogoUrl: json['companyLogoUrl'] as String?,
        title: (json['title'] as String?) ?? '',
        description: json['description'] as String?,
        coinCost: ((json['coinCost'] as num?) ?? 0).toInt(),
      );
}
