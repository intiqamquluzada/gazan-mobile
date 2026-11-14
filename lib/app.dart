import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/platform/app_variant.dart';
import 'core/push/push_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/profile/application/profile_settings_controller.dart';
import 'features/loyalty/application/loyalty_providers.dart';
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
      ..invalidate(myActiveRewardsProvider);
    return MaterialApp.router(
      title: AppVariant.isBusinessApp ? 'Qazan İşletme' : AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      routerConfig: router,
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
