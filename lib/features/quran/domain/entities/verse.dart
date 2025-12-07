class Verse {
  final int id;
  final int surahId;
  final int verseNumber;
  final String textUthmani;
  final String? verseKey;
  final int? pageNumber;

  const Verse({
    required this.id,
    required this.surahId,
    required this.verseNumber,
    required this.textUthmani,
    this.verseKey,
    this.pageNumber,
  });
}
