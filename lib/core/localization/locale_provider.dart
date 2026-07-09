import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

/// Holds the current language choice. Accessible from the home screen
/// per Orynta_Brand_Guide.md §6 ("Language switcher always accessible
/// from home, not buried in settings").
class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'orynta_language_code';

  String _languageCode = 'en';
  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  AppStrings get strings => AppStrings.of(_languageCode);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(_prefKey) ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (code == _languageCode) return;
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }
}
