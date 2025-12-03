class Surah {
  final int id;
  final String nameSimple;
  final String nameArabic;
  final int versesCount;
  final String revelationPlace;
  final List<int> pages;

  Surah({
    required this.id,
    required this.nameSimple,
    required this.nameArabic,
    required this.versesCount,
    required this.revelationPlace,
    required this.pages,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      nameSimple: json['name_simple'],
      nameArabic: json['name_arabic'],
      versesCount: json['verses_count'],
      revelationPlace: json['revelation_place'],
      pages: List<int>.from(json['pages']),
    );
  }
}
