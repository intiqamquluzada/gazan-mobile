import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

/// Desktop till only: brings the app window to the front (restoring it if
/// minimised) so the cashier sees a customer who is waiting. Windows does
/// not let a background app steal focus outright, so the window is briefly
/// pinned on top, which also flashes it in the taskbar.
class WindowAttention {
  const WindowAttention._();

  static bool get _desktop => !kIsWeb && Platform.isWindows;

  static Future<void> init() async {
    if (!_desktop) return;
    await windowManager.ensureInitialized();
  }

  static Future<void> raise() async {
    if (!_desktop) return;
    try {
      if (await windowManager.isMinimized()) await windowManager.restore();
      await windowManager.show();
      await windowManager.setAlwaysOnTop(true);
      await windowManager.focus();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await windowManager.setAlwaysOnTop(false);
    } catch (_) {
      // Purely cosmetic; the customer window still opens.
    }
  }
}
