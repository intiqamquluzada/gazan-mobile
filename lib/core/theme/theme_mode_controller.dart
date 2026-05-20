import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-selected app theme mode, persisted across launches via
/// [SharedPreferences].
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.light) {
    _restore();
  }

  static const String _key = 'qazan.theme_mode';

  Future<void> _restore() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    switch (p.getString(_key)) {
      case 'dark':
        state = ThemeMode.dark;
      case 'system':
        state = ThemeMode.system;
      case 'light':
        state = ThemeMode.light;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setString(_key, mode.name);
  }
}

final StateNotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
  (Ref ref) => ThemeModeController(),
);
