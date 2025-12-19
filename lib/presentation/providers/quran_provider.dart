import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart'; // Keep for ProcessingState if needed, or use AudioService
import '../../features/quran/domain/entities/surah.dart';
import '../../features/quran/domain/entities/verse.dart';
import '../../features/quran/domain/repositories/quran_repository.dart';
import '../../core/services/audio_service.dart';
import '../../core/api/qul_service.dart';
import '../../core/cache/models/qul_recitation_model.dart';
import '../../core/di/injection_container.dart';
import 'settings_provider.dart';

enum MushafType { hafs, warsh }

class QuranProvider with ChangeNotifier {
  final QuranRepository _repository = sl<QuranRepository>();
  final AudioService _audioService = sl<AudioService>();
  final QulService _qulService = QulService(); // Direct instantiation for now, or use sl<QulService>() if registered
  
  MushafType _mushafType = MushafType.hafs;
  MushafType get mushafType => _mushafType;

  // Current Verse Highlight
  String? _currentVerseKey;
  String? get currentVerseKey => _currentVerseKey;

  QuranProvider() {
    // Listen to audio service for verse updates
    _audioService.currentVerseStream.listen((key) {
      if (_currentVerseKey != key) {
        _currentVerseKey = key;
        notifyListeners();
      }
    });
    
    // Listen to player state
    _audioService.playerStateStream.listen((state) {
        _isPlaying = state.playing;
        notifyListeners();
    });
  }

  void setMushafType(MushafType type) {
    _mushafType = type;
    notifyListeners();
  }

  String getPageAssetPath(int pageNumber) {
    final paddedNum = pageNumber.toString().padLeft(3, '0');
    return 'assets/images/pages/page$paddedNum.png';
  }

  List<Surah> _surahs = [];
  List<Surah> get surahs => _surahs;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  final Map<int, List<Verse>> _versesCache = {};

  Future<void> fetchSurahs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _repository.getSurahs();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Verse>> getVersesForSurah(int surahId) async {
    if (_versesCache.containsKey(surahId)) {
      return _versesCache[surahId]!;
    }

    try {
      final verses = await _repository.getVerses(surahId);
      _versesCache[surahId] = verses;
      return verses;
    } catch (e) {
      rethrow;
    }
  }

  // Cache for page verses
  final Map<int, List<Verse>> _pageVersesCache = {};

  Future<List<Verse>> getVersesForPage(int pageNumber) async {
    if (_pageVersesCache.containsKey(pageNumber)) {
      return _pageVersesCache[pageNumber]!;
    }
    
    // API V4 logic usually requires fetching by Surah or Juz. 
    // If we don't have getVersesByPage in generic Repo, we might need a workaround 
    // or assume getVerses(page: X) works (which it does in our Repo impl)
    try {
      // Assuming Repo has getVerses(surahId, page) or similar. 
      // Actually our V4 repo has: Future<List<Verse>> getVerses(int surahId, {int? page});
      // But page-based fetching without Surah ID is tricky with Quran.com API structure 
      // unless we use /verses/by_page/{page_number} endpoint which we didn't add yet.
      // FOR NOW: Let's assume we load Interaction Data for page lookup locally OR 
      // we implement getVersesByPage in Repo properly. 
      // V3 impl used getVersesByPage. Let's use the Interaction Data we loaded to get Verses IDs!
      
      // Let's rely on _pageLines for identification, but if we need Text/Translation 
      // we might need to fetch.
      
      // Temporary fallback: Return empty or use what we have.
      // Ideally we update Repo to have getVersesByPage.
      return []; 
    } catch (e) {
      rethrow;
    }
  }

  Surah? getSurahForPage(int pageNumber) {
    try {
      return _surahs.firstWhere((s) {
        if (s.pages.length < 2) return false;
        return pageNumber >= s.pages[0] && pageNumber <= s.pages[1];
      });
    } catch (e) {
      return null;
    }
  }

  // Audio Logic
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String? _currentSurahName;
  String? get currentSurahName => _currentSurahName;
  
  // Reciter info delegated to SettingsProvider
  String get currentReciterId => sl<SettingsProvider>().reciterId;
  String get currentReciterName => sl<SettingsProvider>().reciterName;

  // Bookmarks
  List<int> _bookmarks = [];
  List<int> get bookmarks => _bookmarks;

  // Night Mode
  bool _isNightMode = false;
  bool get isNightMode => _isNightMode;

  void toggleNightMode() {
    _isNightMode = !_isNightMode;
    notifyListeners();
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('bookmarks');
    if (stored != null) {
      _bookmarks = stored.map((e) => int.parse(e)).toList();
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    if (_bookmarks.contains(pageNumber)) {
      _bookmarks.remove(pageNumber);
    } else {
      _bookmarks.add(pageNumber);
    }
    await prefs.setStringList('bookmarks', _bookmarks.map((e) => e.toString()).toList());
    notifyListeners();
  }

  bool isPageBookmarked(int pageNumber) {
    return _bookmarks.contains(pageNumber);
  }

  // Interaction Data
  final Map<int, Map<int, List<Verse>>> _pageLines = {};

  Future<void> loadInteractionData() async {
    if (_pageLines.isNotEmpty) return;

    try {
      final csvString = await rootBundle.loadString('assets/csv/medina.csv');
      final List<String> lines = csvString.split('\n');
      
      for (int i = 1; i < lines.length; i++) {
        final row = lines[i].trim();
        if (row.isEmpty) continue;
        
        final parts = row.split(',');
        if (parts.length < 6) continue;

        final pageNum = int.tryParse(parts[1]) ?? 0;
        final surahId = int.tryParse(parts[3]) ?? 0;
        final ayahNum = int.tryParse(parts[4]) ?? 0;
        final lineNum = int.tryParse(parts[5]) ?? 0;

        if (pageNum == 0 || lineNum == 0 || ayahNum <= 0) continue; 

        _pageLines.putIfAbsent(pageNum, () => {});
        _pageLines[pageNum]!.putIfAbsent(lineNum, () => []);
        
        final verse = Verse(
          id: 0, 
          surahId: surahId,       // Added logic
          verseNumber: ayahNum,   // Added logic
          verseKey: '$surahId:$ayahNum',
          textUthmani: '', 
          pageNumber: pageNum,
        );
        
        _pageLines[pageNum]![lineNum]!.add(verse);
      }
      notifyListeners();
    } catch (e) {
      print("Error loading interaction data: $e");
    }
  }

  List<Verse> getVersesForLine(int page, int line) {
    if (_pageLines.containsKey(page) && _pageLines[page]!.containsKey(line)) {
      return _pageLines[page]![line]!;
    }
    return [];
  }

  // New Play Logic
  Future<void> playPage(int pageNumber) async {
    // Find first verse of the page from Interaction Data
    if (_pageLines.containsKey(pageNumber)) {
       final lines = _pageLines[pageNumber]!;
       // Sort keys to get line 1
       final sortedLines = lines.keys.toList()..sort();
       if (sortedLines.isNotEmpty) {
         final firstLine = sortedLines.first;
         final verses = lines[firstLine];
         if (verses != null && verses.isNotEmpty) {
           await playAyah(verses.first);
           return;
         }
       }
    }
    // Fallback if no interaction data
    print("No interaction data found for page $pageNumber to play audio.");
  }

  Future<void> playAyah(Verse verse) async {
    try {
      // 1. Get Audio URL from QulService using SettingsProvider for ID
      final reciterId = sl<SettingsProvider>().reciterId;
      final audioUrl = _qulService.getAyahAudioUrl(reciterId, verse.surahId, verse.verseNumber);
      
      // Set info
      final surah = _surahs.firstWhere((s) => s.id == verse.surahId, orElse: () => const Surah(id: 0, nameSimple: '', nameArabic: '', versesCount: 0, revelationPlace: '', pages: []));
      if (surah.id != 0) {
          _currentSurahName = surah.nameSimple;
          notifyListeners();
      }

      // 2. Play using AudioService
      await _audioService.playAudioUrl(audioUrl);
      
      // Note: We are now playing Ayah by Ayah. 
      // Auto-play next logic would need to be implemented in AudioService listener or here if desired.
      
    } catch (e) {
      print("Error playing ayah: $e");
    }
  }
  
  Future<void> stopAudio() async {
    await _audioService.stop();
  }
}
