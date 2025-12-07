class Surah {
  final int id;
  final String nameSimple;
  final String nameArabic;
  final int versesCount;
  final String revelationPlace;
  final List<int> pages; 

  const Surah({
    required this.id,
    required this.nameSimple,
    required this.nameArabic,
    required this.versesCount,
    required this.revelationPlace,
    required this.pages,
  });
}
