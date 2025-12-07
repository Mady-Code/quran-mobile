import '../../features/quran/domain/entities/reciter.dart';

class AlQuranApi {
  static const String _cdnBaseUrl = 'https://cdn.islamic.network/quran';
  static const String _everyAyahBaseUrl = 'https://everyayah.com/data';
  static const int _defaultBitrate = 128;

  // Available reciters with their editions
  static const Map<String, String> reciters = {
    'ar.alafasy': 'Mishary Rashid Alafasy',
    'ar.abdulbasitmurattal': 'Abdul Basit (Murattal)',
    'ar.abdulsamad': 'Abdul Basit (Mujawwad)',
    'ar.shaatree': 'Abu Bakr Al-Shatri',
    'ar.hanirifai': 'Hani Ar-Rifai',
    'ar.husary': 'Mahmoud Khalil Al-Hussary',
    'ar.minshawi': 'Mohamed Siddiq Al-Minshawi',
    'ar.muhammadayyoub': 'Muhammad Ayyoub',
    'ar.muhammadjibreel': 'Muhammad Jibreel',
  };

  // EveryAyah reciter folders (fallback)
  static const Map<String, String> everyAyahReciters = {
    'ar.alafasy': 'Alafasy_128kbps',
    'ar.abdulbasitmurattal': 'Abdul_Basit_Murattal_192kbps',
    'ar.shaatree': 'Abu_Bakr_Ash-Shaatree_128kbps',
    'ar.husary': 'Husary_128kbps',
    'ar.minshawi': 'Minshawy_Murattal_128kbps',
  };

  /// Get audio URL for a complete surah
  static String getSurahAudioUrl(int surahNumber, String edition) {
    return '$_cdnBaseUrl/audio-surah/$_defaultBitrate/$edition/$surahNumber.mp3';
  }

  /// Get fallback URL from EveryAyah (first ayah of surah)
  /// Note: EveryAyah provides per-ayah audio, so we return the first ayah
  static String? getEveryAyahFallbackUrl(int surahNumber, String edition) {
    final folder = everyAyahReciters[edition];
    if (folder == null) return null;
    
    // Format: 001001.mp3 (surah 1, ayah 1)
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final ayahPadded = '001'; // First ayah
    return '$_everyAyahBaseUrl/$folder/$surahPadded$ayahPadded.mp3';
  }

  /// Get audio URL for a specific ayah (absolute ayah number 1-6236)
  static String getAyahAudioUrl(int ayahNumber, String edition) {
    return '$_cdnBaseUrl/audio/$_defaultBitrate/$edition/$ayahNumber.mp3';
  }

  /// Get reciter name from edition
  static String getReciterName(String edition) {
    return reciters[edition] ?? 'Unknown Reciter';
  }

  /// Get list of available reciters
  static List<Reciter> getAvailableReciters() {
    return reciters.entries.map((entry) => Reciter(
      id: entry.key.hashCode,
      name: entry.value,
      style: 'Murattal',
      edition: entry.key,
    )).toList();
  }
}
