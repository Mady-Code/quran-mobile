import '../../domain/entities/surah.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/recitation.dart';
import '../../domain/repositories/quran_repository.dart';
import '../../../../core/data/local_data_source.dart';
import '../../../../core/api/quran_api_client.dart';
import '../../../../core/api/alquran_api.dart';
import '../../../../core/cache/cache_service.dart';
import '../../../../core/cache/models/recitation_cache_model.dart';

class QuranRepositoryImpl implements QuranRepository {
  final LocalDataSource _localDataSource;
  final QuranApiClient _apiClient;
  final CacheService _cacheService;

  QuranRepositoryImpl({
    required LocalDataSource localDataSource,
    required QuranApiClient apiClient,
    required CacheService cacheService,
  })  : _localDataSource = localDataSource,
        _apiClient = apiClient,
        _cacheService = cacheService;

  @override
  Future<List<Surah>> getSurahs() async {
    // 1. Check cache first
    final cachedSurahs = _cacheService.getSurahs();
    if (cachedSurahs.isNotEmpty) {
      print('✅ Cache hit: returning ${cachedSurahs.length} surahs from cache');
      return cachedSurahs;
    }

    // 2. Cache miss - load from local JSON
    print('⚠️ Cache miss: loading surahs from local data source');
    final surahs = await _localDataSource.getChapters();

    // 3. Save to cache for next time
    await _cacheService.saveSurahs(surahs);
    print('💾 Saved ${surahs.length} surahs to cache');

    return surahs;
  }

  @override
  Future<List<Verse>> getVerses(int surahId, {int? page}) async {
    // For now, return empty list - verses will be loaded from local data later
    // or we can keep using API for verses if needed
    return [];
  }

  @override
  Future<Recitation?> getChapterAudio(int chapterId, {String? edition}) async {
    // Use edition from parameter or default
    final selectedEdition = edition ?? 'ar.alafasy';
    
    // 1. Check cache first
    final cached = _cacheService.getRecitation(chapterId);
    if (cached != null && cached.edition == selectedEdition) {
      print('✅ Cache hit: returning recitation for chapter $chapterId from cache');
      return cached.toEntity();
    }

    // 2. Generate audio URL directly (no API call needed!)
    print('📦 Generating audio URL for chapter $chapterId with edition $selectedEdition');
    try {
      final audioUrl = AlQuranApi.getSurahAudioUrl(chapterId, selectedEdition);
      final reciterName = AlQuranApi.getReciterName(selectedEdition);
      
      final recitation = Recitation(
        chapterId: chapterId,
        audioUrl: audioUrl,
        reciterName: reciterName,
        edition: selectedEdition,
      );
      
      // 3. Save to cache
      await _cacheService.saveRecitation(
        RecitationCacheModel.fromEntity(recitation),
      );
      print('💾 Saved recitation for chapter $chapterId to cache');

      return recitation;
    } catch (e) {
      print('❌ Error creating recitation: $e');
      return null;
    }
  }
}
