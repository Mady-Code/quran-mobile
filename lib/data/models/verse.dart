class Verse {
  final int id;
  final String verseKey;
  final String textUthmani;
  final String translation; // Changed to non-nullable based on new fromJson logic

  final int? pageNumber;

  Verse({
    required this.id,
    required this.verseKey,
    required this.textUthmani,
    required this.translation, // Changed to required
    this.pageNumber,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'],
      verseKey: json['verse_key'],
      textUthmani: json['text_uthmani'],
      translation: (json['translations'] != null && (json['translations'] as List).isNotEmpty)
          ? json['translations'][0]['text']
          : '', // Assigns empty string if no translation
      pageNumber: json['page_number'],
    );
  }
}
