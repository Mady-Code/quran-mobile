import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/surah.dart';
import '../models/verse.dart';

class QuranRepository {
  Future<List<Surah>> getAllSurahs() async {
    try {
      final String response = await rootBundle.loadString('assets/json/chapters.json');
      final data = json.decode(response);
      final List<dynamic> chapters = data['chapters'];
      return chapters.map((json) => Surah.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error loading surahs from assets: $e');
    }
  }

  Future<List<Verse>> getVerses(int chapterId) async {
    try {
      final String response = await rootBundle.loadString('assets/json/quran.json');
      final data = json.decode(response);
      final List<dynamic> allVerses = data['verses'];
      
      // Filter verses for the specific chapter
      // The verse_key format is "chapterId:verseId"
      final verses = allVerses.where((v) {
        final keyParts = v['verse_key'].split(':');
        return int.parse(keyParts[0]) == chapterId;
      }).toList();

      return verses.map((json) => Verse.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error loading verses from assets: $e');
    }
  }
  Future<List<Verse>> getVersesByPage(int pageNumber) async {
    try {
      final String response = await rootBundle.loadString('assets/json/quran.json');
      final data = json.decode(response);
      final List<dynamic> allVerses = data['verses'];
      
      final verses = allVerses.where((v) {
        return v['page_number'] == pageNumber;
      }).toList();

      return verses.map((json) => Verse.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error loading verses for page $pageNumber: $e');
    }
  }
}
