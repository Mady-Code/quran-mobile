import 'package:hive/hive.dart';
import '../../../features/quran/domain/entities/surah.dart';

part 'surah_cache_model.g.dart';

@HiveType(typeId: 0)
class SurahCacheModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String nameSimple;

  @HiveField(2)
  final String nameArabic;

  @HiveField(3)
  final int versesCount;

  @HiveField(4)
  final String revelationPlace;

  @HiveField(5)
  final List<int> pages;

  SurahCacheModel({
    required this.id,
    required this.nameSimple,
    required this.nameArabic,
    required this.versesCount,
    required this.revelationPlace,
    required this.pages,
  });

  // Convert to domain entity
  Surah toEntity() {
    return Surah(
      id: id,
      nameSimple: nameSimple,
      nameArabic: nameArabic,
      versesCount: versesCount,
      revelationPlace: revelationPlace,
      pages: pages,
    );
  }

  // Create from domain entity
  factory SurahCacheModel.fromEntity(Surah surah) {
    return SurahCacheModel(
      id: surah.id,
      nameSimple: surah.nameSimple,
      nameArabic: surah.nameArabic,
      versesCount: surah.versesCount,
      revelationPlace: surah.revelationPlace,
      pages: surah.pages,
    );
  }
}
