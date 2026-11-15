import 'package:flutter/material.dart';

/// Central colour tokens — the ONLY place hex values live.
///
/// Palette: fresh green on white / soft mint — a calm, premium loyalty feel.
/// Green is an accent, not a fill: canvases stay white or near-white mint,
/// cards are white, and green marks actions, active states and progress. Widgets reference
/// these tokens (or [AppPalette] via `context.palette` when a value must
/// follow light/dark mode) — never raw hex.
///
/// Usage rules worth remembering:
/// * [action] — every primary action button ("Coin topla", "Davam et",
///   "Yadda saxla"). [caramel] — secondary emphasis: active tab, icons,
///   indicators; for caramel *text* use [caramelText] (AA contrast).
/// * [reward] is ONLY for reward moments: progress fill, filled stamps,
///   "you earned points" notices, gift/reward cards, star ratings.
/// * [highlight] is rare: the "Yeni" badge / new-content tags, at most
///   1–2 places on a screen.
class AppColors {
  const AppColors._();

  // ── Backgrounds ────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5FAF3); // near-white mint canvas
  static const Color surface = Color(0xFFFFFFFF); // cards
  static const Color surfaceMuted = Color(0xFFF0F5EE); // chips, icon buttons
  static const Color surfaceAccent = Color(0xFFE6F4DF); // selected / accent

  // ── Brand green surfaces (balance card, loyalty card, QR disc) ──
  // Mid-tone green, never forest-dark. White text stays AA (5.3:1).
  static const Color surfaceDark = Color(0xFF2C7A3A);
  static const Color surfaceDark2 = Color(0xFF4FA548);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkMuted = Color(0xFFE6F4DF);

  /// Brand green gradient for premium cards, splash, QR disc.
  static const List<Color> heroGradient = <Color>[surfaceDark2, surfaceDark];

  /// Light mint band behind the discover header (dark text on top).
  static const List<Color> heroLightGradient = <Color>[
    Color(0xFFF1F8EE),
    Color(0xFFE2F1DB),
  ];

  // ── Actions ────────────────────────────────────────────────────────
  // Mid-tone green; white label 4.8:1 (AA). Filled buttons draw
  // [actionGradient] on top of it.
  static const Color action = Color(0xFF2A8236);
  static const Color actionPressed = Color(0xFF23702E);
  static const Color onAction = Color(0xFFFFFFFF);
  static const Color caramel = Color(0xFF3E9A45); // icons / indicators
  static const Color caramelText = Color(0xFF23702E); // green as text (AA)
  static const Color caramelSoft = Color(0xFFE8F5E3); // secondary button bg (mint)

  /// Primary button fill: light-to-mid green, top-left to bottom-right.
  static const List<Color> actionGradient = <Color>[
    Color(0xFF55AD45),
    Color(0xFF2A8236),
  ];

  // ── Reward (reward moments ONLY — see class doc) ──────────────────
  static const Color reward = Color(0xFFE5A93A);
  static const Color rewardSoft = Color(0xFFFBF1E0);
  static const Color onReward = Color(0xFF3A2A12);

  // ── Highlight (rare: "Yeni" badge, new-content tags) ──────────────
  static const Color highlight = Color(0xFF2A8236);
  static const Color highlightSoft = Color(0xFFE6F4DF);

  // ── Text ───────────────────────────────────────────────────────────
  /// Deep green for brand headings (logo word-mark, sign-in title).
  static const Color ink = Color(0xFF1C4A2A);
  static const Color textPrimary = Color(0xFF1A2B20);
  // 5.3:1 on the mint canvas.
  static const Color textSecondary = Color(0xFF5F6B63);
  // 3.3:1 on white. Hints, placeholders,
  // disabled and inactive icons only — never body copy.
  static const Color textTertiary = Color(0xFF828C85);

  // ── Status ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22A861); // dots, icons, fills
  static const Color successText = Color(0xFF146E3E); // green text (AA)
  static const Color successSoft = Color(0xFFE7F5EC);
  static const Color danger = Color(0xFFD9485F); // dots, hearts, icons
  static const Color dangerText = Color(0xFFB7344B); // red text (AA)
  static const Color dangerSoft = Color(0xFFFBE9EC);

  // ── Lines, tracks, shadows ─────────────────────────────────────────
  static const Color border = Color(0xFFE3EBE0);
  static const Color borderStrong = Color(0xFFD3DED0);
  static const Color divider = Color(0xFFE6ECE3);
  static const Color progressTrack = Color(0xFFE3EBE0);
  static const Color progressTrackOnDark = Color(0xFF6DB865);
  static const Color stampEmpty = Color(0xFFE8EEE5);

  /// Base tint for card / elevated shadows — rgb(30, 58, 36).
  static const Color shadowTint = Color(0xFF1E3A24);

  // ── Category accents (max 4; everything else uses the neutral pair) ─
  static const Color catCoffee = Color(0xFF8A5A1F);
  static const Color catCoffeeBg = Color(0xFFFBF1E3);
  static const Color catRestaurant = Color(0xFFAE2F49); // spec #C23A55 (AA)
  static const Color catRestaurantBg = Color(0xFFFCE8EC);
  static const Color catBeauty = Color(0xFF5B3FA6);
  static const Color catBeautyBg = Color(0xFFEFEAFB);
  static const Color catTeal = Color(0xFF2F6F8A);
  static const Color catTealBg = Color(0xFFE6F2F6);
  static const Color catNeutral = textSecondary;
  static const Color catNeutralBg = surfaceMuted;

  // ── Scrims (photos, story viewer) ──────────────────────────────────
  static const Color scrim = Color(0x8C000000); // rgba(0,0,0,.55)
  static const Color media = Color(0xFF000000); // camera / story backdrop
  static const Color transparent = Color(0x00000000);
}

/// Dark-mode values for the same token names (only the ones that change).
class AppColorsDark {
  const AppColorsDark._();

  static const Color background = Color(0xFF0F1511);
  static const Color surface = Color(0xFF18201A);
  static const Color surfaceMuted = Color(0xFF202A23);
  static const Color surfaceAccent = Color(0xFF243A2A);
  static const Color textPrimary = Color(0xFFEEF3EE);
  static const Color textSecondary = Color(0xFFA9B5AC);
  static const Color textTertiary = Color(0xFF7C887F);
  static const Color action = Color(0xFF6CC46A);
  static const Color actionPressed = Color(0xFF5AB058);
  static const Color onAction = Color(0xFF0F1511);
  static const Color caramel = Color(0xFF6CC46A);
  static const Color caramelText = Color(0xFF7FD07C);
  static const Color caramelSoft = Color(0xFF1F3324);
  static const Color reward = Color(0xFFE8BD78);
  static const Color rewardSoft = Color(0xFF3A2F1E);
  static const Color highlight = Color(0xFF7FD07C);
  static const Color highlightSoft = Color(0xFF1F3324);
  static const Color border = Color(0xFF2A352D);
  static const Color divider = Color(0xFF2A352D);
  static const Color progressTrack = Color(0xFF2A352D);
  static const Color stampEmpty = Color(0xFF2A352D);
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
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceMuted: AppColors.surfaceMuted,
    surfaceAccent: AppColors.surfaceAccent,
    textPrimary: AppColors.textPrimary,
    ink: AppColors.ink,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    action: AppColors.action,
    onAction: AppColors.onAction,
    caramel: AppColors.caramel,
    caramelText: AppColors.caramelText,
    caramelSoft: AppColors.caramelSoft,
    reward: AppColors.reward,
    rewardSoft: AppColors.rewardSoft,
    highlight: AppColors.highlight,
    highlightSoft: AppColors.highlightSoft,
    border: AppColors.border,
    divider: AppColors.divider,
    progressTrack: AppColors.progressTrack,
    stampEmpty: AppColors.stampEmpty,
    successSoft: AppColors.successSoft,
    dangerSoft: AppColors.dangerSoft,
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

  /// Deep brand green used for headings; light text in dark mode.
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
