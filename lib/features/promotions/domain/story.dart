/// One slide inside a brand's story sequence.
class Story {
  const Story({
    required this.id,
    required this.companyId,
    required this.headline,
    required this.body,
    required this.emoji,
    required this.gradientStartHex,
    required this.gradientEndHex,
    this.cta,
    this.duration = const Duration(seconds: 5),
  });

  final String id;
  final String companyId;
  final String headline;
  final String body;
  final String emoji;
  final int gradientStartHex;
  final int gradientEndHex;
  final String? cta;
  final Duration duration;

  factory Story.fromJson(Map<String, dynamic> json) {
    final int seconds = ((json['durationSeconds'] as num?) ?? 5).toInt();
    return Story(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      headline: (json['headline'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      emoji: (json['emoji'] as String?) ?? '✨',
      gradientStartHex:
          (json['gradientStartHex'] as num?)?.toInt() ?? 0xFF1F2937,
      gradientEndHex: (json['gradientEndHex'] as num?)?.toInt() ?? 0xFF111827,
      cta: json['cta'] as String?,
      duration: Duration(seconds: seconds),
    );
  }
}

class StoryGroup {
  const StoryGroup({
    required this.companyId,
    required this.stories,
    this.viewed = false,
  });

  final String companyId;
  final List<Story> stories;
  final bool viewed;

  StoryGroup copyWith({bool? viewed}) =>
      StoryGroup(companyId: companyId, stories: stories, viewed: viewed ?? this.viewed);

  factory StoryGroup.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = (json['stories'] as List<dynamic>?) ?? <dynamic>[];
    return StoryGroup(
      companyId: json['companyId'] as String,
      stories: raw
          .cast<Map<String, dynamic>>()
          .map(Story.fromJson)
          .toList(growable: false),
    );
  }
}
