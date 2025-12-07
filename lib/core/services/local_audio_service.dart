import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocalAudioSegment {
  final int index;
  final int startMs;
  final int endMs;
  
  const LocalAudioSegment({
    required this.index,
    required this.startMs,
    required this.endMs,
  });
  
  factory LocalAudioSegment.fromList(List<dynamic> list) {
    return LocalAudioSegment(
      index: list[0] as int,
      startMs: list[1] as int,
      endMs: list[2] as int,
    );
  }
}

class LocalAyahSegmentData {
  final List<LocalAudioSegment> segments;
  final int durationSec;
  final int durationMs;
  final int timestampFrom;
  final int timestampTo;
  
  const LocalAyahSegmentData({
    required this.segments,
    required this.durationSec,
    required this.durationMs,
    required this.timestampFrom,
    required this.timestampTo,
  });
  
  factory LocalAyahSegmentData.fromJson(Map<String, dynamic> json) {
    return LocalAyahSegmentData(
      segments: (json['segments'] as List)
          .map((s) => LocalAudioSegment.fromList(s as List))
          .toList(),
      durationSec: json['duration_sec'] as int,
      durationMs: json['duration_ms'] as int,
      timestampFrom: json['timestamp_from'] as int,
      timestampTo: json['timestamp_to'] as int,
    );
  }
}

class LocalSurahAudioData {
  final int surahNumber;
  final String audioUrl;
  final int duration;
  
  const LocalSurahAudioData({
    required this.surahNumber,
    required this.audioUrl,
    required this.duration,
  });
  
  factory LocalSurahAudioData.fromJson(Map<String, dynamic> json) {
    return LocalSurahAudioData(
      surahNumber: json['surah_number'] as int,
      audioUrl: json['audio_url'] as String,
      duration: json['duration'] as int,
    );
  }
}

class LocalAudioService {
  static LocalAudioService? _instance;
  static LocalAudioService get instance => _instance ??= LocalAudioService._();
  
  LocalAudioService._();
  
  Map<int, LocalSurahAudioData>? _surahsAudio;
  Map<String, LocalAyahSegmentData>? _segments;
  
  /// Load surahs audio data from local JSON
  Future<Map<int, LocalSurahAudioData>> loadSurahsAudio() async {
    if (_surahsAudio != null) return _surahsAudio!;
    
    try {
      print('📥 Loading surahs audio from assets...');
      final jsonString = await rootBundle.loadString('assets/json/read/surahs_audio.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _surahsAudio = {};
      jsonData.forEach((key, value) {
        final surahNum = int.parse(key);
        _surahsAudio![surahNum] = LocalSurahAudioData.fromJson(value);
      });
      
      print('✅ Loaded ${_surahsAudio!.length} surahs audio data');
      return _surahsAudio!;
    } catch (e) {
      print('❌ Error loading surahs audio: $e');
      rethrow;
    }
  }
  
  /// Load segments data from local JSON
  Future<Map<String, LocalAyahSegmentData>> loadSegments() async {
    if (_segments != null) return _segments!;
    
    try {
      print('📥 Loading segments from assets...');
      final jsonString = await rootBundle.loadString('assets/json/read/segments.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _segments = {};
      jsonData.forEach((key, value) {
        _segments![key] = LocalAyahSegmentData.fromJson(value);
      });
      
      print('✅ Loaded ${_segments!.length} ayah segments');
      return _segments!;
    } catch (e) {
      print('❌ Error loading segments: $e');
      rethrow;
    }
  }
  
  /// Get audio URL for a surah
  Future<String?> getSurahAudioUrl(int surahNumber) async {
    final surahs = await loadSurahsAudio();
    return surahs[surahNumber]?.audioUrl;
  }
  
  /// Get segment data for a specific ayah
  Future<LocalAyahSegmentData?> getAyahSegments(int surah, int ayah) async {
    final segments = await loadSegments();
    return segments['$surah:$ayah'];
  }
  
  /// Get all segment data for a surah
  Future<Map<int, LocalAyahSegmentData>> getSurahSegments(int surahNumber) async {
    final allSegments = await loadSegments();
    final surahSegments = <int, LocalAyahSegmentData>{};
    
    allSegments.forEach((key, value) {
      final parts = key.split(':');
      if (parts.length == 2) {
        final surah = int.parse(parts[0]);
        final ayah = int.parse(parts[1]);
        
        if (surah == surahNumber) {
          surahSegments[ayah] = value;
        }
      }
    });
    
    return surahSegments;
  }
}
