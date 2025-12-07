import '../entities/surah.dart';
import '../entities/verse.dart';
import '../entities/recitation.dart';

abstract class QuranRepository {
  Future<List<Surah>> getSurahs();
  Future<List<Verse>> getVerses(int surahId, {int? page});
  Future<Recitation?> getChapterAudio(int surahId, {String? edition});
}
