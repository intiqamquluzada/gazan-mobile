class Promotion {
  const Promotion({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientStartHex,
    required this.gradientEndHex,
    required this.cta,
    this.companyId,
    this.endsAt,
  });

  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final String emoji;
  final int gradientStartHex;
  final int gradientEndHex;
  final String cta;
  final String? companyId;
  final DateTime? endsAt;

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      companyId: json['companyId'] as String?,
      tag: (json['tag'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      emoji: (json['emoji'] as String?) ?? '🎁',
      gradientStartHex:
          (json['gradientStartHex'] as num?)?.toInt() ?? 0xFF1F2937,
      gradientEndHex: (json['gradientEndHex'] as num?)?.toInt() ?? 0xFF111827,
      cta: (json['cta'] as String?) ?? 'Bax',
      endsAt: json['endsAt'] != null
          ? DateTime.parse(json['endsAt'] as String)
          : null,
    );
  }
}
