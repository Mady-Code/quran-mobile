import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/quran/domain/entities/surah.dart';
import '../../features/quran/domain/entities/verse.dart';

class LocalDataSource {
  Future<List<Surah>> getChapters() async {
    try {
      final jsonString = await rootBundle.loadString('assets/json/chapters.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> chaptersJson = jsonData['chapters'];
      
      return chaptersJson.map((json) => Surah(
        id: json['id'],
        nameSimple: json['name_simple'],
        nameArabic: json['name_arabic'],
        versesCount: json['verses_count'],
        revelationPlace: json['revelation_place'],
        pages: List<int>.from(json['pages']),
      )).toList();
    } catch (e) {
      throw Exception('Failed to load local chapters: $e');
    }
  }

  Future<List<Verse>> getVerses(int chapterId) async {
    try {
      final jsonString = await rootBundle.loadString('assets/json/quran.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> versesJson = jsonData['verses'];
      
      final filteredVerses = versesJson.where((v) {
        final keyParts = v['verse_key'].split(':');
        return int.parse(keyParts[0]) == chapterId;
      }).toList();

      return filteredVerses.map((json) {
        final keyParts = json['verse_key'].toString().split(':');
        final verseNum = keyParts.length > 1 ? int.parse(keyParts[1]) : 0;
        
        return Verse(
          id: json['id'],
          surahId: chapterId,
          verseNumber: json['verse_number'] ?? verseNum,
          verseKey: json['verse_key'],
          textUthmani: json['text_uthmani'],
          pageNumber: json['page_number'],
        );
      }).toList();
    } catch (e) {
      print('=== LOCAL DATA SOURCE ERROR: Failed to load local verses ===');
      print(e);
      throw Exception('Failed to load local verses: $e');
    }
  }
}
