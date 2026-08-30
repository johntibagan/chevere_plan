import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema de la app en disco. Cargar en bootstrap **antes** de [runApp]
/// para que el primer frame ya use la preferencia (sin flash claro↔oscuro).
abstract final class AppThemeModeStore {
  static const prefsKey = 'theme_mode';

  static ThemeMode _cached = ThemeMode.system;

  /// Valor listo para el primer [MaterialApp] (default: sistema).
  static ThemeMode get current => _cached;

  /// Primera instalación / sin clave → [ThemeMode.system].
  static ThemeMode parse(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.system,
      };

  static String encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  static Future<ThemeMode> loadBeforeRunApp() async {
    final prefs = await SharedPreferences.getInstance();
    _cached = parse(prefs.getString(prefsKey));
    return _cached;
  }

  static Future<void> save(ThemeMode mode) async {
    _cached = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, encode(mode));
  }
}
