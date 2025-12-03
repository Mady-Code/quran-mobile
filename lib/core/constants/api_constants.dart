class ApiConstants {
  static const String baseUrl = 'https://api.quran.com/api/v4';
  static const String audioBaseUrl = 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee'; // Example reciter

  // Endpoints
  static const String chapters = '$baseUrl/chapters';
  static String verses(int chapterId) => '$baseUrl/verses/by_chapter/$chapterId?language=en&words=true&translations=131&fields=text_uthmani';
  // Note: 131 is Clear Quran translation ID. Adjust as needed.
}
