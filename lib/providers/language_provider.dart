// lib/providers/language_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  static const _languageKey = 'krishidrishti_language';
  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  Locale _locale = const Locale('en');

  LanguageProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;
  AppStrings get strings => AppStrings(_locale);
  String get languageCode => _locale.languageCode;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageKey) ?? 'en';
    if (AppStrings.supportedLanguageCodes.contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (!AppStrings.supportedLanguageCodes.contains(languageCode)) {
      return;
    }
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  String get speechLocaleCode {
    switch (_locale.languageCode) {
      case 'hi':
        return 'hi_IN';
      case 'mr':
        return 'mr_IN';
      default:
        return 'en_IN';
    }
  }

  String get ttsLanguageCode {
    switch (_locale.languageCode) {
      case 'hi':
        return 'hi-IN';
      case 'mr':
        return 'mr-IN';
      default:
        return 'en-IN';
    }
  }
}
