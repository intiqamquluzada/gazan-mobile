import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

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
      statusBarColor: Colors.transparent,
    ),
  );
  await initializeDateFormatting('az');

  runApp(const ProviderScope(child: QazanApp()));
}
