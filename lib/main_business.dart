import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/platform/app_variant.dart';
import 'core/platform/window_attention.dart';

/// Entry point of the desktop till app (`qazan_isletme.exe`):
///
///   flutter build windows --release -t lib/main_business.dart
///
/// Same code as the phone app, restricted to owner and cashier accounts.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppVariant.isBusinessApp = true;
  await WindowAttention.init();
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting();
  runApp(const ProviderScope(child: QazanApp()));
}
