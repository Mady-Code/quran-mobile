import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/quran/domain/entities/surah.dart';

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
}
