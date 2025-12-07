import '../../domain/entities/surah.dart';

class SurahModel extends Surah {
  const SurahModel({
    required super.id,
    required super.nameSimple,
    required super.nameArabic,
    required super.versesCount,
    required super.revelationPlace,
    required super.pages,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: json['id'],
      nameSimple: json['name_simple'],
      nameArabic: json['name_arabic'],
      versesCount: json['verses_count'],
      revelationPlace: json['revelation_place'],
      pages: List<int>.from(json['pages']),
    );
  }
}
