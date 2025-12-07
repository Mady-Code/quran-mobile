import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _reciterEditionKey = 'reciter_edition';
  static const String _reciterNameKey = 'reciter_name';
  static const String _nightModeKey = 'night_mode';
  
  final SharedPreferences _prefs;
  
  String _reciterEdition = 'ar.alafasy'; // Default: Mishary Rashid Alafasy
  String _reciterName = 'Mishary Rashid Alafasy';
  bool _nightMode = false;
  
  SettingsProvider(this._prefs) {
    _loadSettings();
  }
  
  String get reciterEdition => _reciterEdition;
  String get reciterName => _reciterName;
  bool get nightMode => _nightMode;
  
  Future<void> _loadSettings() async {
    _reciterEdition = _prefs.getString(_reciterEditionKey) ?? 'ar.alafasy';
    _reciterName = _prefs.getString(_reciterNameKey) ?? 'Mishary Rashid Alafasy';
    _nightMode = _prefs.getBool(_nightModeKey) ?? false;
    notifyListeners();
  }
  
  Future<void> setReciter(String edition, String name) async {
    _reciterEdition = edition;
    _reciterName = name;
    await _prefs.setString(_reciterEditionKey, edition);
    await _prefs.setString(_reciterNameKey, name);
    notifyListeners();
  }
  
  Future<void> toggleNightMode() async {
    _nightMode = !_nightMode;
    await _prefs.setBool(_nightModeKey, _nightMode);
    notifyListeners();
  }
}
