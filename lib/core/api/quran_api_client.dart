import 'package:dio/dio.dart';

class QuranApiClient {
  final Dio _dio;
  static const String _baseUrl = 'https://api.quran.com/api/v4';

  QuranApiClient({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  Future<Map<String, dynamic>> getChapters() async {
    try {
      final response = await _dio.get('/chapters');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load chapters: $e');
    }
  }

  Future<Map<String, dynamic>> getVerses(int chapterId, {int? page}) async {
    try {
      final response = await _dio.get('/quran/verses/uthmani', queryParameters: {
        'chapter_number': chapterId,
        'page': page, 
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to load verses: $e');
    }
  }

  // Fetch chapter recitation with timestamps (segments)
  Future<Map<String, dynamic>?> getChapterRecitation(int chapterId, {int reciterId = 7}) async {
    try {
      final response = await _dio.get('/chapter_recitations/$reciterId/$chapterId');
      return response.data; // Contains 'audio_file': { 'audio_url': '...', 'timestamps': [...] }
    } catch (e) {
       print('Error fetching audio: $e');
       return null;
    }
  }

  // Fetch list of available reciters
  Future<Map<String, dynamic>> getReciters() async {
    try {
      final response = await _dio.get('/resources/recitations', queryParameters: {
        'language': 'en',
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to load reciters: $e');
    }
  }
}
