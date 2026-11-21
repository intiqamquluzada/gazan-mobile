import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/push/push_service.dart';
import './core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never fetch fonts from fonts.gstatic.com at runtime. On devices that
  // can't reach Google's CDN (offline, or networks that block gstatic)
  // the old behaviour threw "Failed host lookup: fonts.gstatic.com" and
  // broke the UI. With this off, google_fonts uses the Inter files
  // bundled in assets/google_fonts/ — and if those are missing it simply
  // falls back to the system font instead of crashing.
  GoogleFonts.config.allowRuntimeFetching = false;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
    ),
  );
  // The app serves Azerbaijan and Türkiye (plus ru/en UI), so load the
  // date symbols for all of them, not just Azerbaijani.
  await initializeDateFormatting();

  // One container shared by start-up code and the widget tree, so the
  // push service set up here is the same instance the app uses later.
  final ProviderContainer container = ProviderContainer();
  // Phone notifications: a quiet no-op until Firebase is configured.
  await container.read(pushServiceProvider).init();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const QazanApp(),
  ));
}
