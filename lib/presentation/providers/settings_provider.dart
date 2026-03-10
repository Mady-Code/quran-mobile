import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/quran/domain/entities/mushaf_type.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _reciterIdKey = 'reciter_id';
  static const String _reciterNameKey = 'reciter_name';
  static const String _nightModeKey = 'night_mode';
  static const String _mushafTypeKey = 'mushaf_type';
  
  final SharedPreferences _prefs;
  
  String _reciterId = '118'; // Default: Mishary Rashid Alafasy
  String _reciterName = 'Mishary Rashid Alafasy';
  bool _nightMode = false;
  MushafType _mushafType = MushafType.hafs;
  
  SettingsProvider(this._prefs) {
    _loadSettings();
  }
  
  String get reciterId => _reciterId;
  String get reciterName => _reciterName;
  bool get nightMode => _nightMode;
  MushafType get mushafType => _mushafType;
  
  Future<void> _loadSettings() async {
    _reciterId = _prefs.getString(_reciterIdKey) ?? '118';
    _reciterName = _prefs.getString(_reciterNameKey) ?? 'Mishary Rashid Alafasy';
    _nightMode = _prefs.getBool(_nightModeKey) ?? false;
    final mushafTypeName = _prefs.getString(_mushafTypeKey);
    if (mushafTypeName != null) {
      _mushafType = MushafType.values.firstWhere(
        (e) => e.name == mushafTypeName,
        orElse: () => MushafType.hafs,
      );
    }
    notifyListeners();
  }
  
  Future<void> setReciter(String id, String name) async {
    _reciterId = id;
    _reciterName = name;
    await _prefs.setString(_reciterIdKey, id);
    await _prefs.setString(_reciterNameKey, name);
    notifyListeners();
  }
  
  Future<void> toggleNightMode() async {
    _nightMode = !_nightMode;
    await _prefs.setBool(_nightModeKey, _nightMode);
    notifyListeners();
  }

  Future<void> setMushafType(MushafType type) async {
    _mushafType = type;
    await _prefs.setString(_mushafTypeKey, type.name);
    notifyListeners();
  }
}
