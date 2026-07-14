import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's Dark Mode preference, set from Profile > Settings.
/// Mirrors `LocaleProvider`'s SharedPreferences-backed load/set pattern.
class ThemeModeProvider extends ChangeNotifier {
  static const _prefKey = 'orynta_dark_mode';

  bool _darkMode = false;
  bool get darkMode => _darkMode;
  ThemeMode get mode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_prefKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    if (enabled == _darkMode) return;
    _darkMode = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }
}
