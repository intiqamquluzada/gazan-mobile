import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Which product this build is. The Windows `qazan_isletme.exe` starts from
/// `lib/main_business.dart`, which flips [isBusinessApp] before `runApp`.
class AppVariant {
  const AppVariant._();

  static bool isBusinessApp = false;
}

/// What the current device can do. Everything hardware-related checks here
/// first, so none of the phone-only plugins are ever called on Windows.
class PlatformCaps {
  const PlatformCaps._();

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;

  /// NFC reading and native sign-in exist on phones only.
  static bool get hasNfc => isMobile;

  /// Writing NDEF to a blank tag is Android-only in the plugin.
  static bool get canWriteNfc => isAndroid;

  /// GPS is only worth asking for on a phone.
  static bool get hasLocation => isMobile;
}
