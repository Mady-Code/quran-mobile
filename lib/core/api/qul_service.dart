import 'package:dio/dio.dart';
import '../cache/models/qul_recitation_model.dart';

class QulService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://qul.tarteel.ai';
  
  /// Get list of available reciters
  /// For now, we use a curated list of popular reciters with segments
  List<QulReciter> getReciters() {
    return [
      const QulReciter(
        id: '118',
        name: 'Mishary Rashid Alafasy',
        style: 'Murattal',
        format: 'Ayah by Ayah',
        hasSegments: true,
      ),
      const QulReciter(
        id: '102',
        name: 'Abdur-Rahman as-Sudais',
        style: 'Murattal',
        format: 'Ayah by Ayah',
        hasSegments: true,
      ),
      const QulReciter(
        id: '105',
        name: 'Mohamed Siddiq al-Minshawi',
        style: 'Murattal',
        format: 'Ayah by Ayah',
        hasSegments: true,
      ),
      const QulReciter(
        id: '117',
        name: 'Abu Bakr al-Shatri',
        style: 'Murattal',
        format: 'Ayah by Ayah',
        hasSegments: true,
      ),
      const QulReciter(
        id: '110',
        name: 'Mahmoud Khalil Al-Husary',
        style: 'Murattal',
        format: 'Ayah by Ayah',
        hasSegments: true,
      ),
    ];
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
