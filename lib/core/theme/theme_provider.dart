import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  final SharedPreferences _preferences;

  ThemeMode _themeMode;

  ThemeProvider._(this._preferences, this._themeMode);

  ThemeMode get themeMode => _themeMode;

  static Future<ThemeProvider> create() async {
    final preferences = await SharedPreferences.getInstance();

    final savedTheme = preferences.getString(_themeKey);

    final themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => ThemeMode.system,
    );

    return ThemeProvider._(preferences, themeMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    await _preferences.setString(_themeKey, mode.name);

    _themeMode = mode;
    notifyListeners();
  }
}
