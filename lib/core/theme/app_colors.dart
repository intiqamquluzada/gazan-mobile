import 'package:flutter/material.dart';

/// Central colour tokens — the ONLY place hex values live.
///
/// Palette: warm orange on cream — energetic, modern loyalty feel.
/// Orange is an accent, not a fill: canvases stay cream or white, cards are
/// white, and orange marks actions, active states and progress.
///
/// Light / dark: every token that differs between modes is a getter that
/// returns the value for the current brightness, so `AppColors.textPrimary`
/// (and every [AppTextStyles] style built on it) is correct in dark mode
/// without each widget reaching for `context.palette`. The app root calls
/// [AppColors.useBrightness] whenever the effective theme changes and then
/// rebuilds the tree. The raw values live in [AppColorsLight] and
/// [AppColorsDark]; [AppPalette] exposes the same values as a ThemeExtension.
///
/// Usage rules worth remembering:
/// * [action] — every primary action button ("Coin topla", "Davam et",
///   "Yadda saxla"). [caramel] — secondary emphasis: active tab, icons,
///   indicators; for accent *text* use [caramelText] (AA contrast).
/// * [reward] is ONLY for reward moments: progress fill, filled stamps,
///   "you earned points" notices, gift/reward cards, star ratings.
/// * [highlight] is rare: the "Yeni" badge / new-content tags, at most
///   1–2 places on a screen.
class AppColors {
  const AppColors._();

  static bool _dark = false;

  /// True while the app shows its dark theme.
  static bool get isDark => _dark;

  /// Points the mode-aware tokens at [b]. Returns true when it changed.
  static bool useBrightness(Brightness b) {
    final bool dark = b == Brightness.dark;
    if (dark == _dark) return false;
    _dark = dark;
    return true;
  }

  static Color _m(Color light, Color dark) => _dark ? dark : light;

  // ── Backgrounds ────────────────────────────────────────────────────
  static Color get background =>
      _m(AppColorsLight.background, AppColorsDark.background);
  static Color get surface => _m(AppColorsLight.surface, AppColorsDark.surface);
  static Color get surfaceMuted =>
      _m(AppColorsLight.surfaceMuted, AppColorsDark.surfaceMuted);
  static Color get surfaceAccent =>
      _m(AppColorsLight.surfaceAccent, AppColorsDark.surfaceAccent);

  // ── Brand orange surfaces (balance card, loyalty card, QR disc) ──
  // Same in both modes: white text on deep orange stays AA.
  static const Color surfaceDark = Color(0xFFEE6416);
  static const Color surfaceDark2 = Color(0xFFFFA23A);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkMuted = Color(0xFFFFE6D5);

  /// Brand orange gradient for premium cards, splash, QR disc.
  static const List<Color> heroGradient = <Color>[surfaceDark2, surfaceDark];

  /// Soft band behind the discover header (dark text on top).
  static List<Color> get heroLightGradient => _dark
      ? const <Color>[Color(0xFF221A15), Color(0xFF2B2019)]
      : const <Color>[Color(0xFFFFF6EE), Color(0xFFFFE9DA)];

  // ── Actions ────────────────────────────────────────────────────────
  static Color get action => _m(AppColorsLight.action, AppColorsDark.action);
  static Color get actionPressed =>
      _m(AppColorsLight.actionPressed, AppColorsDark.actionPressed);
  static Color get onAction =>
      _m(AppColorsLight.onAction, AppColorsDark.onAction);
  static Color get caramel => _m(AppColorsLight.caramel, AppColorsDark.caramel);
  static Color get caramelText =>
      _m(AppColorsLight.caramelText, AppColorsDark.caramelText);
  static Color get caramelSoft =>
      _m(AppColorsLight.caramelSoft, AppColorsDark.caramelSoft);

  /// Primary button fill: warm amber to orange, top-left to bottom-right —
  /// the "gold coin" glow of the brand, never a warning red.
  static const List<Color> actionGradient = <Color>[
    Color(0xFFFFA93A),
    Color(0xFFF76B15),
  ];

  /// Soft warm glow under primary call-to-action pills.
  static const Color actionGlow = Color(0xFFFF8A2A);

  // ── Reward (reward moments ONLY — see class doc) ──────────────────
  static Color get reward => _m(AppColorsLight.reward, AppColorsDark.reward);
  static Color get rewardSoft =>
      _m(AppColorsLight.rewardSoft, AppColorsDark.rewardSoft);
  static const Color onReward = Color(0xFF3A2A12);

  /// Reward gold as text / numbers (AA on cards in both modes).
  static Color get rewardText =>
      _m(const Color(0xFF9A620A), const Color(0xFFF2C26B));

  // ── Highlight (rare: "Yeni" badge, new-content tags) ──────────────
  static Color get highlight =>
      _m(AppColorsLight.highlight, AppColorsDark.highlight);
  static Color get highlightSoft =>
      _m(AppColorsLight.highlightSoft, AppColorsDark.highlightSoft);

  // ── Text ───────────────────────────────────────────────────────────
  /// Deep warm brown for brand headings (logo word-mark, sign-in title).
  static Color get ink => _m(AppColorsLight.ink, AppColorsDark.textPrimary);
  static Color get textPrimary =>
      _m(AppColorsLight.textPrimary, AppColorsDark.textPrimary);
  static Color get textSecondary =>
      _m(AppColorsLight.textSecondary, AppColorsDark.textSecondary);

  /// Hints, placeholders, disabled and inactive icons only — never body copy.
  static Color get textTertiary =>
      _m(AppColorsLight.textTertiary, AppColorsDark.textTertiary);

  // ── Status ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22A861); // dots, icons, fills
  static Color get successText =>
      _m(const Color(0xFF146E3E), const Color(0xFF5FD08F));
  static Color get successSoft =>
      _m(AppColorsLight.successSoft, AppColorsDark.successSoft);
  static const Color danger = Color(0xFFD9485F); // dots, hearts, icons
  static Color get dangerText =>
      _m(const Color(0xFFB7344B), const Color(0xFFF2899A));
  static Color get dangerSoft =>
      _m(AppColorsLight.dangerSoft, AppColorsDark.dangerSoft);

  // ── Lines, tracks, shadows ─────────────────────────────────────────
  static Color get border => _m(AppColorsLight.border, AppColorsDark.border);
  static Color get borderStrong =>
      _m(AppColorsLight.borderStrong, AppColorsDark.borderStrong);
  static Color get divider => _m(AppColorsLight.divider, AppColorsDark.divider);
  static Color get progressTrack =>
      _m(AppColorsLight.progressTrack, AppColorsDark.progressTrack);
  static const Color progressTrackOnDark = Color(0xFFFFB487);
  static Color get stampEmpty =>
      _m(AppColorsLight.stampEmpty, AppColorsDark.stampEmpty);

  /// Base tint for card / elevated shadows — warm brown.
  static const Color shadowTint = Color(0xFF4A2A14);

  // ── Wave backdrop (soft organic shapes behind auth / list screens) ──
  static Color get waveStrong =>
      _m(const Color(0xFFFFE6D3), const Color(0xFF241B15));
  static Color get waveSoft =>
      _m(const Color(0xFFFFF0E4), const Color(0xFF1C1612));

  // ── Category accents (max 4; everything else uses the neutral pair) ─
  static Color get catCoffee =>
      _m(const Color(0xFF8A5A1F), const Color(0xFFE3AE6E));
  static Color get catCoffeeBg =>
      _m(const Color(0xFFFBF1E3), const Color(0xFF33261A));
  static Color get catRestaurant =>
      _m(const Color(0xFFAE2F49), const Color(0xFFF28AA0));
  static Color get catRestaurantBg =>
      _m(const Color(0xFFFCE8EC), const Color(0xFF3A1F27));
  static Color get catBeauty =>
      _m(const Color(0xFF5B3FA6), const Color(0xFFB9A3F2));
  static Color get catBeautyBg =>
      _m(const Color(0xFFEFEAFB), const Color(0xFF2A2340));
  static Color get catTeal =>
      _m(const Color(0xFF2F6F8A), const Color(0xFF80C6E0));
  static Color get catTealBg =>
      _m(const Color(0xFFE6F2F6), const Color(0xFF1C2E36));
  static Color get catNeutral => textSecondary;
  static Color get catNeutralBg => surfaceMuted;

  // ── Scrims (photos, story viewer) ──────────────────────────────────
  static const Color scrim = Color(0x8C000000); // rgba(0,0,0,.55)
  static const Color media = Color(0xFF000000); // camera / story backdrop
  static const Color transparent = Color(0x00000000);
}

/// Light-mode values of the mode-aware tokens.
class AppColorsLight {
  const AppColorsLight._();

  static const Color background = Color(0xFFFFF8F3); // warm cream canvas
  static const Color surface = Color(0xFFFFFFFF); // cards
  static const Color surfaceMuted = Color(0xFFFFF1E7); // chips, icon buttons
  static const Color surfaceAccent = Color(0xFFFFE6D5); // selected / accent
  // Warm orange (hue ~22°), kept clear of red. Labels on it are bold.
  static const Color action = Color(0xFFF06416);
  static const Color actionPressed = Color(0xFFD9560F);
  static const Color onAction = Color(0xFFFFFFFF);
  static const Color caramel = Color(0xFFF57A20); // icons / indicators
  static const Color caramelText = Color(0xFFB54A0C); // orange as text (AA)
  static const Color caramelSoft = Color(0xFFFFEDE0); // secondary button bg
  static const Color reward = Color(0xFFF4B12E);
  static const Color rewardSoft = Color(0xFFFFF4DC);
  static const Color highlight = Color(0xFFF06416);
  static const Color highlightSoft = Color(0xFFFFE6D5);
  static const Color ink = Color(0xFF2B1A12);
  static const Color textPrimary = Color(0xFF1F1712);
  static const Color textSecondary = Color(0xFF6E6259); // 5.4:1 on cream
  static const Color textTertiary = Color(0xFF948880);
  static const Color successSoft = Color(0xFFE7F5EC);
  static const Color dangerSoft = Color(0xFFFBE9EC);
  static const Color border = Color(0xFFF1E4DA);
  static const Color borderStrong = Color(0xFFE6D5C8);
  static const Color divider = Color(0xFFF3E8DF);
  static const Color progressTrack = Color(0xFFF3E3D6);
  static const Color stampEmpty = Color(0xFFF6EAE0);
}

/// Dark-mode values of the mode-aware tokens.
class AppColorsDark {
  const AppColorsDark._();

  static const Color background = Color(0xFF14100D);
  static const Color surface = Color(0xFF1E1814);
  static const Color surfaceMuted = Color(0xFF2A211C);
  static const Color surfaceAccent = Color(0xFF3A2A20);
  static const Color textPrimary = Color(0xFFF7EFE9);
  static const Color textSecondary = Color(0xFFBFB2A8);
  static const Color textTertiary = Color(0xFF8E8178);
  static const Color action = Color(0xFFFF8F3F);
  static const Color actionPressed = Color(0xFFF57A20);
  // White on the orange gradient, same as light mode.
  static const Color onAction = Color(0xFFFFFFFF);
  static const Color caramel = Color(0xFFFF8A3D);
  static const Color caramelText = Color(0xFFFF9A57);
  static const Color caramelSoft = Color(0xFF3A2418);
  static const Color reward = Color(0xFFF2C26B);
  static const Color rewardSoft = Color(0xFF3A2F1E);
  static const Color highlight = Color(0xFFFF9A57);
  static const Color highlightSoft = Color(0xFF3A2418);
  static const Color border = Color(0xFF352A22);
  static const Color borderStrong = Color(0xFF453830);
  static const Color divider = Color(0xFF352A22);
  static const Color progressTrack = Color(0xFF352A22);
  static const Color stampEmpty = Color(0xFF352A22);
  static const Color successSoft = Color(0xFF1C2E22);
  static const Color dangerSoft = Color(0xFF3A1F24);
}

/// Mode-aware token set, exposed as a [ThemeExtension] so widgets can read
/// the right value for the current brightness: `context.palette.surface`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceAccent,
    required this.textPrimary,
    required this.ink,
    required this.textSecondary,
    required this.textTertiary,
    required this.action,
    required this.onAction,
    required this.caramel,
    required this.caramelText,
    required this.caramelSoft,
    required this.reward,
    required this.rewardSoft,
    required this.highlight,
    required this.highlightSoft,
    required this.border,
    required this.divider,
    required this.progressTrack,
    required this.stampEmpty,
    required this.successSoft,
    required this.dangerSoft,
  });

  static const AppPalette light = AppPalette(
    background: AppColorsLight.background,
    surface: AppColorsLight.surface,
    surfaceMuted: AppColorsLight.surfaceMuted,
    surfaceAccent: AppColorsLight.surfaceAccent,
    textPrimary: AppColorsLight.textPrimary,
    ink: AppColorsLight.ink,
    textSecondary: AppColorsLight.textSecondary,
    textTertiary: AppColorsLight.textTertiary,
    action: AppColorsLight.action,
    onAction: AppColorsLight.onAction,
    caramel: AppColorsLight.caramel,
    caramelText: AppColorsLight.caramelText,
    caramelSoft: AppColorsLight.caramelSoft,
    reward: AppColorsLight.reward,
    rewardSoft: AppColorsLight.rewardSoft,
    highlight: AppColorsLight.highlight,
    highlightSoft: AppColorsLight.highlightSoft,
    border: AppColorsLight.border,
    divider: AppColorsLight.divider,
    progressTrack: AppColorsLight.progressTrack,
    stampEmpty: AppColorsLight.stampEmpty,
    successSoft: AppColorsLight.successSoft,
    dangerSoft: AppColorsLight.dangerSoft,
  );

  static const AppPalette dark = AppPalette(
    background: AppColorsDark.background,
    surface: AppColorsDark.surface,
    surfaceMuted: AppColorsDark.surfaceMuted,
    surfaceAccent: AppColorsDark.surfaceAccent,
    textPrimary: AppColorsDark.textPrimary,
    ink: AppColorsDark.textPrimary,
    textSecondary: AppColorsDark.textSecondary,
    textTertiary: AppColorsDark.textTertiary,
    action: AppColorsDark.action,
    onAction: AppColorsDark.onAction,
    caramel: AppColorsDark.caramel,
    caramelText: AppColorsDark.caramelText,
    caramelSoft: AppColorsDark.caramelSoft,
    reward: AppColorsDark.reward,
    rewardSoft: AppColorsDark.rewardSoft,
    highlight: AppColorsDark.highlight,
    highlightSoft: AppColorsDark.highlightSoft,
    border: AppColorsDark.border,
    divider: AppColorsDark.divider,
    progressTrack: AppColorsDark.progressTrack,
    stampEmpty: AppColorsDark.stampEmpty,
    successSoft: AppColorsDark.successSoft,
    dangerSoft: AppColorsDark.dangerSoft,
  );

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceAccent;
  final Color textPrimary;

  /// Deep brand brown used for headings; light text in dark mode.
  final Color ink;
  final Color textSecondary;
  final Color textTertiary;
  final Color action;
  final Color onAction;
  final Color caramel;
  final Color caramelText;
  final Color caramelSoft;
  final Color reward;
  final Color rewardSoft;
  final Color highlight;
  final Color highlightSoft;
  final Color border;
  final Color divider;
  final Color progressTrack;
  final Color stampEmpty;
  final Color successSoft;
  final Color dangerSoft;

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      (other is AppPalette && t >= 0.5) ? other : this;
}

extension AppPaletteX on BuildContext {
  /// Mode-aware colour tokens for the current theme.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
