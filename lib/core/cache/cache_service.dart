import 'package:hive_flutter/hive_flutter.dart';
import 'models/surah_cache_model.dart';
import 'models/recitation_cache_model.dart';
import '../../features/quran/domain/entities/surah.dart';
import '../data/local_data_source.dart';

class CacheService {
  static const String _surahBoxName = 'surahs';
  static const String _recitationsBoxName = 'recitations';

  late Box<SurahCacheModel> _surahBox;
  late Box<RecitationCacheModel> _recitationBox;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SurahCacheModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecitationCacheModelAdapter());
    }

    // Open boxes with error handling for migration
    try {
      _surahBox = await Hive.openBox<SurahCacheModel>(_surahBoxName);
      _recitationBox = await Hive.openBox<RecitationCacheModel>(_recitationsBoxName);
    } catch (e) {
      // If opening fails due to incompatible format, delete and recreate
      print('⚠️ Cache format incompatible, clearing cache: $e');
      await Hive.deleteBoxFromDisk(_surahBoxName);
      await Hive.deleteBoxFromDisk(_recitationsBoxName);
      
      // Retry opening
      _surahBox = await Hive.openBox<SurahCacheModel>(_surahBoxName);
      _recitationBox = await Hive.openBox<RecitationCacheModel>(_recitationsBoxName);
      print('✅ Cache cleared and recreated');
    }

    _isInitialized = true;

    // Migrate initial data if cache is empty
    await _migrateInitialData();
  }

  Future<void> _migrateInitialData() async {
    if (_surahBox.isEmpty) {
      try {
        print('📦 Cache is empty, migrating initial data from JSON...');
        final localDataSource = LocalDataSource();
        final surahs = await localDataSource.getChapters();
        await saveSurahs(surahs);
        print('✅ Migrated ${surahs.length} surahs to Hive cache');
      } catch (e) {
        print('❌ Error migrating initial data: $e');
      }
    }
  }

  // Surah CRUD
  Future<void> saveSurahs(List<Surah> surahs) async {
    final cacheModels = surahs.map((s) => SurahCacheModel.fromEntity(s)).toList();
    await _surahBox.clear();
    for (var i = 0; i < cacheModels.length; i++) {
      await _surahBox.put(cacheModels[i].id, cacheModels[i]);
    }
  }

  List<Surah> getSurahs() {
    if (_surahBox.isEmpty) return [];
    return _surahBox.values.map((c) => c.toEntity()).toList();
  }

  Surah? getSurah(int id) {
    final cached = _surahBox.get(id);
    return cached?.toEntity();
  }

  // Recitation CRUD
  Future<void> saveRecitation(RecitationCacheModel recitation) async {
    await _recitationBox.put(recitation.chapterId, recitation);
  }

  RecitationCacheModel? getRecitation(int chapterId) {
    return _recitationBox.get(chapterId);
  }

  // Clear all caches
  Future<void> clearAll() async {
    await _surahBox.clear();
    await _recitationBox.clear();
  }

  // Get cache stats
  Map<String, int> getStats() {
    return {
      'surahs': _surahBox.length,
      'recitations': _recitationBox.length,
    };
  }
}
