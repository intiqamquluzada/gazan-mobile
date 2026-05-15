import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User-selected app theme mode. Persisted in memory only for now —
/// swap to SharedPreferences when needed.
final StateProvider<ThemeMode> themeModeProvider =
    StateProvider<ThemeMode>((Ref ref) => ThemeMode.light);
