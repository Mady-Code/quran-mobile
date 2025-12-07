import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  const VerseModel({
    required super.id,
    required super.surahId,
    required super.verseNumber,
    required super.textUthmani,
    super.verseKey,
    super.pageNumber,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    final verseKey = json['verse_key'] as String;
    final parts = verseKey.split(':');
    final surahId = int.parse(parts[0]);
    final verseNumber = int.parse(parts[1]);

    return VerseModel(
      id: json['id'],
      surahId: surahId,
      verseNumber: verseNumber,
      textUthmani: json['text_uthmani'],
      verseKey: verseKey,
      pageNumber: json['page_number'],
    );
  }
}
