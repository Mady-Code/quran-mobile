import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/quran/domain/entities/mushaf_type.dart';
import '../../core/di/injection_container.dart';
import '../../core/services/audio_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _reciterIdKey = 'reciter_id';
  static const String _reciterNameKey = 'reciter_name';
  static const String _nightModeKey = 'night_mode';
  static const String _mushafTypeKey = 'mushaf_type';
  static const String _reciterAudioAssetsKey = 'reciter_audio_assets';
  static const String _arabicFontSizeKey = 'arabic_font_size';
  
  final SharedPreferences _prefs;
  
  String _reciterId = '411'; // Default: Mishari
  String _reciterName = 'Mishari Rashid al-`Afasy';
  String? _reciterAudioAssets;
  bool _nightMode = false;
  MushafType _mushafType = MushafType.hafs;
  double _arabicFontSize = 32.0;
  
  SettingsProvider(this._prefs) {
    _loadSettings();
  }
  
  String get reciterId => _reciterId;
  String get reciterName => _reciterName;
  String? get reciterAudioAssets => _reciterAudioAssets;
  bool get nightMode => _nightMode;
  MushafType get mushafType => _mushafType;
  double get arabicFontSize => _arabicFontSize;
  
  Future<void> _loadSettings() async {
    _reciterId = _prefs.getString(_reciterIdKey) ?? '411';
    _reciterName = _prefs.getString(_reciterNameKey) ?? 'Mishary Rashid al-`Afasy';
    _reciterAudioAssets = _prefs.getString(_reciterAudioAssetsKey);
    
    // Recovery for missing audio_assets (from previous saved preferences)
    if (_reciterAudioAssets == null || _reciterAudioAssets!.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString('assets/json/read/qul_reciters.json');
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final reciter = jsonList.firstWhere((r) => r['id'] == _reciterId, orElse: () => null);
        if (reciter != null && reciter['audio_assets'] != null) {
          _reciterAudioAssets = reciter['audio_assets'];
          await _prefs.setString(_reciterAudioAssetsKey, _reciterAudioAssets!);
        }
      } catch (e) {
        // Ignored
      }
    }

    _nightMode = _prefs.getBool(_nightModeKey) ?? false;
    _arabicFontSize = _prefs.getDouble(_arabicFontSizeKey) ?? 32.0;
    
    final mushafTypeName = _prefs.getString(_mushafTypeKey);
    if (mushafTypeName != null) {
      _mushafType = MushafType.values.firstWhere(
        (e) => e.name == mushafTypeName,
        orElse: () => MushafType.hafs,
      );
    }
    notifyListeners();
  }
  
  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size;
    await _prefs.setDouble(_arabicFontSizeKey, size);
    notifyListeners();
  }
  
  Future<void> setReciter(String id, String name, String? audioAssets) async {
    _reciterId = id;
    _reciterName = name;
    _reciterAudioAssets = audioAssets;
    await _prefs.setString(_reciterIdKey, id);
    await _prefs.setString(_reciterNameKey, name);
    if (audioAssets != null) {
      await _prefs.setString(_reciterAudioAssetsKey, audioAssets);
    } else {
      await _prefs.remove(_reciterAudioAssetsKey);
    }
    
    // Switch the reciter seamlessly in the audio service
    try {
      await sl<AudioService>().switchReciter(id, name, audioAssets);
    } catch (e) {
      print('Error switching reciter stream: $e');
    }
    
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
