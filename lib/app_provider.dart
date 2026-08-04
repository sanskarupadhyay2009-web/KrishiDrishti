import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/soil_scan.dart';

/// Single source of truth for state that needs to survive navigation
/// between screens: the chosen language, whether the soil analyzer is
/// "connected", and the scan history.
///
/// Everything is persisted with SharedPreferences so a farmer's language
/// choice and past scans are still there the next time they open the app.
class AppProvider extends ChangeNotifier {
  static const _kLanguageKey = 'isHindi';
  static const _kOnboardedKey = 'hasChosenLanguage';
  static const _kHistoryKey = 'scanHistory';

  bool _isHindi = false;
  bool _hasChosenLanguage = false;
  bool _isDeviceConnected = false;
  List<SoilScan> _history = [];
  bool _isLoaded = false;

  bool get isHindi => _isHindi;
  bool get hasChosenLanguage => _hasChosenLanguage;
  bool get isDeviceConnected => _isDeviceConnected;
  List<SoilScan> get history => List.unmodifiable(_history);
  bool get isLoaded => _isLoaded;
  SoilScan? get lastScan => _history.isEmpty ? null : _history.first;

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    _isHindi = prefs.getBool(_kLanguageKey) ?? false;
    _hasChosenLanguage = prefs.getBool(_kOnboardedKey) ?? false;

    final raw = prefs.getStringList(_kHistoryKey) ?? [];
    _history = raw
        .map((s) => SoilScan.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(bool hindi) async {
    _isHindi = hindi;
    _hasChosenLanguage = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLanguageKey, hindi);
    await prefs.setBool(_kOnboardedKey, true);
  }

  void setDeviceConnected(bool connected) {
    _isDeviceConnected = connected;
    notifyListeners();
  }

  Future<void> addScan(SoilScan scan) async {
    _history = [scan, ..._history];
    notifyListeners();
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _history.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_kHistoryKey, raw);
  }
}
