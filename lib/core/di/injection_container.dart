import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/quran_api_client.dart';
import '../data/local_data_source.dart';
import '../cache/cache_service.dart';
import '../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../features/quran/domain/repositories/quran_repository.dart';
import '../../presentation/providers/settings_provider.dart';
import '../services/audio_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cache Service (must be initialized first)
  final cacheService = CacheService();
  await cacheService.init();
  sl.registerSingleton<CacheService>(cacheService);
  
  print('📊 Cache Stats: ${cacheService.getStats()}');

  // Settings Provider (requires SharedPreferences)
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SettingsProvider>(SettingsProvider(prefs));

  // Core - Data Sources
  sl.registerLazySingleton(() => LocalDataSource());
  sl.registerLazySingleton(() => QuranApiClient());

  // Repository
  sl.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(
      localDataSource: sl(),
      apiClient: sl(),
      cacheService: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton(() => AudioService());
  
  // Storage (Hive) - Already initialized via CacheService
}

