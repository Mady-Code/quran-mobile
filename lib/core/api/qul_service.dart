import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../cache/models/qul_recitation_model.dart';

class QulService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://qul.tarteel.ai';
  
  /// Get list of available reciters from JSON file
  Future<List<QulReciter>> getReciters() async {
    try {
      final jsonString = await rootBundle.loadString('assets/json/read/qul_reciters.json', cache: false);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) {
        return QulReciter(
          id: item['id'] as String,
          name: item['name'] as String,
          style: item['style'] as String? ?? '',
          format: item['format'] as String? ?? '',
          hasSegments: item['has_segments'] as bool? ?? false,
          audioAssets: item['audio_assets'] as String?,
        );
      }).toList();
    } catch (e) {
      print('Error loading reciters: $e');
      return [];
    }
  }
  
  /// Download recitation data (JSON format)
  Future<Map<String, dynamic>> downloadRecitationData(String reciterId) async {
    final url = '$_baseUrl/resources/recitation/$reciterId/download.json';
    
    try {
      print('📥 Downloading QUL recitation data from: $url');
      final response = await _dio.get(url);
      print('✅ Successfully downloaded recitation data');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error downloading recitation data: $e');
      rethrow;
    }
  }
  
  /// Get audio URL for a specific ayah
  String getAyahAudioUrl(String reciterId, int surah, int ayah) {
    final surahPadded = surah.toString().padLeft(3, '0');
    final ayahPadded = ayah.toString().padLeft(3, '0');
    return 'https://qul.tarteel.ai/audio/$reciterId/$surahPadded$ayahPadded.mp3';
  }
  
  /// Get audio URL for a complete surah (if available)
  String getSurahAudioUrl(String reciterId, int surah) {
    final surahPadded = surah.toString().padLeft(3, '0');
    return 'https://qul.tarteel.ai/audio/$reciterId/surah/$surahPadded.mp3';
  }
}
