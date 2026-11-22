import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/platform/app_variant.dart';
import 'core/push/push_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/profile/application/profile_settings_controller.dart';
import 'features/loyalty/application/loyalty_providers.dart';
import 'features/notifications/application/notifications_providers.dart';
import 'features/rewards/application/rewards_providers.dart';
import 'features/wallet/application/wallet_providers.dart';
import 'routing/app_router.dart';
import 'core/utils/formatters.dart';

class QazanApp extends ConsumerWidget {
  const QazanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final String lang = ref.watch(languageProvider);
    final Locale locale = Locale(lang);
    AppFormat.locale = lang;
    final router = ref.watch(appRouterProvider);
    // Tapping a phone notification opens the screen the backend named.
    // The inbox sits above the shells, so it is pushed; shell tabs are
    // switched to (pushing a shell route would stack a second shell).
    final PushService push = ref.read(pushServiceProvider);
    push.attachRouter((String route) =>
        // Pages above the shells are pushed; shell tabs (e.g. /cards) are
        // switched to, since pushing one would stack a second shell.
        route == '/notifications' || route == '/rewards'
            ? router.push(route)
            : router.go(route));
    push.onDataChanged = () => ref
      ..invalidate(coinSummaryProvider)
      ..invalidate(myCardsProvider)
      ..invalidate(myActiveRewardsProvider)
      ..invalidate(notificationInboxProvider)
      ..invalidate(unreadCountProvider);
    return MaterialApp.router(
      title: AppVariant.isBusinessApp ? 'Qazan İşletme' : AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        // Point the mode-aware colour tokens at the theme in use. On a
        // switch, widgets that already built keep the old colours, so the
        // whole tree is rebuilt once on the next frame.
        if (AppColors.useBrightness(Theme.of(context).brightness)) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _rebuildAll(context));
        }
        // Tapping empty space closes the keyboard anywhere in the app.
        // Buttons and fields win their own taps, so only "background"
        // taps reach this detector.
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('az'),
        Locale('en'),
        Locale('ru'),
        Locale('tr'),
      ],
    );
  }
}

/// Marks every element under [context] dirty so they all rebuild with the
/// current colour tokens.
void _rebuildAll(BuildContext context) {
  if (!context.mounted) return;
  void mark(Element e) {
    e.markNeedsBuild();
    e.visitChildren(mark);
  }

  (context as Element).visitChildren(mark);
}
