import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String apiBase = 'https://api.quran.com/api/v4';
const int translationId = 131; // Clear Quran

Future<Map<String, dynamic>> fetchJson(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load $url: ${response.statusCode}');
  }
}

Future<void> main() async {
  print('Fetching chapters...');
  final chaptersRes = await fetchJson('$apiBase/chapters');
  final List<dynamic> chapters = chaptersRes['chapters'];
  
  final List<dynamic> allVerses = [];

  print('Found ${chapters.length} chapters. Fetching verses...');

  for (final chapter in chapters) {
    final int id = chapter['id'];
    print('Fetching Surah $id...');
    
    // Fetch verses with Uthmani text, translation, and page number
    // Using per_page=300 to try and get all verses in one go (max surah length is 286)
    final String url = '$apiBase/verses/by_chapter/$id?language=en&words=false&translations=$translationId&fields=text_uthmani,page_number&per_page=300';
    
    try {
      final res = await fetchJson(url);
      final List<dynamic> verses = res['verses'];
      
      final mappedVerses = verses.map((v) => {
        'id': v['id'],
        'verse_key': v['verse_key'],
        'text_uthmani': v['text_uthmani'],
        'translations': v['translations'],
        'page_number': v['page_number']
      }).toList();
      
      allVerses.addAll(mappedVerses);
    } catch (e) {
      print('Failed to fetch Surah $id: $e');
    }
  }

  final output = {
    'verses': allVerses
  };

  final file = File('assets/json/quran.json');
  await file.writeAsString(json.encode(output));
  print('Saved ${allVerses.length} verses to assets/json/quran.json');
}
