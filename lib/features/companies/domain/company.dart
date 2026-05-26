import 'business_category.dart';

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.tagline,
    required this.category,
    required this.logoEmoji,
    required this.coverColorHex,
    this.address = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.distanceKm,
    this.isFeatured = false,
    this.phone,
    this.instagram,
    this.workingHours,
    this.latitude,
    this.longitude,
    this.amenities = const <String>[],
    this.photoUrls = const <String>[],
    this.menuUrl,
    this.coinRate,
    this.logoUrl,
    this.nameEn,
    this.nameRu,
    this.nameTr,
    this.taglineEn,
    this.taglineRu,
    this.taglineTr,
  });

  final String id;
  final String name;
  final String tagline;
  final BusinessCategory category;
  final String logoEmoji;

  /// Hex (e.g. `0xFF7B3F00`) used as the cover/brand color of the loyalty card.
  final int coverColorHex;

  final String address;
  final double rating;
  final int reviewCount;
  final double? distanceKm;
  final bool isFeatured;

  // ── Owner-managed profile ──
  final String? phone;
  final String? instagram;
  final String? workingHours;
  final double? latitude;
  final double? longitude;

  /// Amenity codes the owner enabled (WIFI, WORKSPACE, MEETING, GARDEN,
  /// PARKING, VEGAN, PET).
  final List<String> amenities;
  final List<String> photoUrls;
  final String? menuUrl;

  /// Coins earned per 1 currency unit spent (e.g. 0.1 → 1000 ₼ = 100 coin).
  final double? coinRate;

  /// Uploaded logo / profile picture. Null → brand monogram fallback.
  final String? logoUrl;

  /// Per-language overrides for the owner-facing editor. `name` /
  /// `tagline` above are already localized for the current request; these
  /// raw fields show what's currently set for each language so the owner
  /// can edit translations side-by-side.
  final String? nameEn;
  final String? nameRu;
  final String? nameTr;
  final String? taglineEn;
  final String? taglineRu;
  final String? taglineTr;

  bool get hasMenu => (menuUrl ?? '').trim().isNotEmpty;

  static List<String> _splitList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    return raw
        .split(RegExp(r'[,\n]'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      tagline: (json['tagline'] as String?) ?? '',
      category: BusinessCategory.fromJson(
          (json['category'] as String?) ?? 'OTHER'),
      logoEmoji: (json['logoEmoji'] as String?) ?? '🏪',
      coverColorHex: (json['coverColorHex'] as num?)?.toInt() ?? 0xFF1F2937,
      address: (json['address'] as String?) ?? '',
      rating: ((json['rating'] as num?) ?? 0).toDouble(),
      reviewCount: ((json['reviewCount'] as num?) ?? 0).toInt(),
      isFeatured: (json['featured'] as bool?) ?? false,
      phone: json['phone'] as String?,
      instagram: json['instagram'] as String?,
      workingHours: json['workingHours'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      amenities: _splitList(json['amenities'] as String?),
      photoUrls: _splitList(json['photoUrls'] as String?),
      menuUrl: json['menuUrl'] as String?,
      coinRate: (json['coinRate'] as num?)?.toDouble(),
      logoUrl: json['logoUrl'] as String?,
      nameEn: json['nameEn'] as String?,
      nameRu: json['nameRu'] as String?,
      nameTr: json['nameTr'] as String?,
      taglineEn: json['taglineEn'] as String?,
      taglineRu: json['taglineRu'] as String?,
      taglineTr: json['taglineTr'] as String?,
    );
  }
}
