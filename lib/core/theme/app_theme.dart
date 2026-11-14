import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Builds Material 3 light and dark themes from the colour tokens in
/// [AppColors] / [AppPalette].
///
/// Design intent: a warm cream canvas with white cards; dark coffee
/// carries every primary action, caramel the secondary emphasis, and gold
/// is reserved for reward moments. Both modes share one builder so they
/// can never drift apart — only the [AppPalette] values differ.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppPalette.light, Brightness.light);

  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness b) {
    final bool dark = b == Brightness.dark;
    final ColorScheme scheme = ColorScheme(
      brightness: b,
      primary: p.action,
      onPrimary: p.onAction,
      primaryContainer: p.caramelSoft,
      onPrimaryContainer: p.textPrimary,
      secondary: p.caramel,
      onSecondary: p.onAction,
      secondaryContainer: p.surfaceAccent,
      onSecondaryContainer: p.textPrimary,
      tertiary: p.highlight,
      onTertiary: AppColors.onDark,
      error: AppColors.danger,
      onError: AppColors.onDark,
      errorContainer: p.dangerSoft,
      onErrorContainer: AppColors.dangerText,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surfaceMuted,
      surfaceContainerHigh: p.surfaceMuted,
      surfaceContainerHighest: p.surfaceAccent,
      outline: dark ? p.border : AppColors.borderStrong,
      outlineVariant: p.border,
      shadow: AppColors.shadowTint,
      scrim: AppColors.scrim,
      inverseSurface: dark ? p.textPrimary : AppColors.surfaceDark,
      onInverseSurface: dark ? p.background : AppColors.onDark,
      inversePrimary: p.caramel,
      surfaceTint: AppColors.transparent,
    );

    ButtonStyle pill(Color bg, Color fg, Color pressed) => ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: WidgetStatePropertyAll(
              AppTextStyles.button.copyWith(fontWeight: FontWeight.w600)),
          elevation: const WidgetStatePropertyAll(0),
          foregroundColor: WidgetStatePropertyAll(fg),
          backgroundColor:
              WidgetStateProperty.resolveWith((Set<WidgetState> s) {
            if (s.contains(WidgetState.disabled)) return p.surfaceMuted;
            if (s.contains(WidgetState.pressed)) return pressed;
            return bg;
          }),
          overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.06)),
        );

    final TextTheme text = GoogleFonts.interTextTheme().apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    );
    final Color pressed =
        dark ? AppColorsDark.actionPressed : AppColors.actionPressed;

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[p],
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: text,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2.copyWith(color: p.textPrimary),
        systemOverlayStyle:
            dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: p.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.divider,
        thickness: 1,
        space: 1,
      ),
      // Primary: dark coffee pill. Secondary (tonal): caramel-soft pill.
      filledButtonTheme: FilledButtonThemeData(
        style: pill(p.action, p.onAction, pressed),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: pill(p.action, p.onAction, pressed),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.action,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: p.border),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.caramelText,
          textStyle: AppTextStyles.button,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: p.textPrimary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceMuted,
        selectedColor: p.surfaceAccent,
        labelStyle: AppTextStyles.bodySm.copyWith(color: p.textPrimary),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: const StadiumBorder(),
      ),
      // Spinners are not reward moments → caramel. Loyalty progress bars
      // set the gold reward fill explicitly.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.caramel,
        linearTrackColor: p.progressTrack,
        circularTrackColor: p.progressTrack,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? p.onAction : p.textTertiary),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? p.action : p.surfaceMuted),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected)
                ? p.action
                : AppColors.transparent),
        checkColor: WidgetStatePropertyAll(p.onAction),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? p.action : p.textTertiary),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.textPrimary,
        unselectedLabelColor: p.textTertiary,
        indicatorColor: p.caramel,
        dividerColor: p.divider,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.action,
        foregroundColor: p.onAction,
      ),
      inputDecorationTheme: _inputDecoration(p),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.action,
        selectionColor: p.caramel.withValues(alpha: 0.3),
        selectionHandleColor: p.caramel,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: AppColors.transparent,
        showDragHandle: true,
        dragHandleColor: p.border,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: AppColors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? p.surfaceMuted : AppColors.surfaceDark,
        contentTextStyle: AppTextStyles.bodySm
            .copyWith(color: dark ? p.textPrimary : AppColors.onDark),
        actionTextColor: dark ? p.caramel : AppColors.surfaceAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: AppColors.transparent,
        height: 64,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(AppTextStyles.caption),
      ),
    );
  }

  static InputDecorationTheme _inputDecoration(AppPalette p) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceMuted,
      hintStyle: AppTextStyles.body.copyWith(color: p.textTertiary),
      prefixIconColor: p.textTertiary,
      suffixIconColor: p.textTertiary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      border: border(AppColors.transparent),
      enabledBorder: border(AppColors.transparent),
      focusedBorder: border(p.caramel, 1.6),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger, 1.6),
    );
  }
}
