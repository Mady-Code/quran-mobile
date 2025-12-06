import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart'; // For processing state
import '../../data/models/surah.dart';
import '../../data/models/verse.dart';
import '../../data/repositories/quran_repository.dart';
import '../../core/services/audio_manager.dart';

enum MushafType { hafs, warsh }

class QuranProvider with ChangeNotifier {
  final QuranRepository _repository = QuranRepository();
  
  MushafType _mushafType = MushafType.hafs;
  MushafType get mushafType => _mushafType;

  void setMushafType(MushafType type) {
    _mushafType = type;
    notifyListeners();
  }

  String getPageAssetPath(int pageNumber) {
    // Determine path based on type
    // Hafs: assets/images/quran/hafs/[number].png
    // Warsh: assets/images/quran/warsh/[number].jpg (or png depending on download)
    
    // Note: The download script uses .png for Hafs and .jpg for Warsh
    // Note: User requested using /images/pages with format pageXXX.png
    final paddedNum = pageNumber.toString().padLeft(3, '0');
    return 'assets/images/pages/page$paddedNum.png';
  }

  List<Surah> _surahs = [];
  List<Surah> get surahs => _surahs;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  // Cache for verses to avoid refetching immediately (simple caching)
  final Map<int, List<Verse>> _versesCache = {};

  Future<void> fetchSurahs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _repository.getAllSurahs();
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

    try {
      final verses = await _repository.getVersesByPage(pageNumber);
      _pageVersesCache[pageNumber] = verses;
      return verses;
    } catch (e) {
      rethrow;
    }
  }

  Surah? getSurahForPage(int pageNumber) {
    // Find the surah that contains this page
    // A surah contains a page if pageNumber is within [startPage, endPage]
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
  final AudioManager _audioManager = AudioManager();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  // Bookmarks
  List<int> _bookmarks = []; // List of page numbers
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

  // Interaction Data (Grid System)
  // Page -> Line (1-15) -> List of Verses (SurahId, VerseNum)
  final Map<int, Map<int, List<Verse>>> _pageLines = {};

  Future<void> loadInteractionData() async {
    if (_pageLines.isNotEmpty) return;

    try {
      final csvString = await rootBundle.loadString('assets/csv/medina.csv');
      final List<String> lines = csvString.split('\n');
      
      // Skip header
      for (int i = 1; i < lines.length; i++) {
        final row = lines[i].trim();
        if (row.isEmpty) continue;
        
        final parts = row.split(',');
        if (parts.length < 6) continue;

        // Header: Tag,PageNum,Juz,Surah,Aayah,LineNum...
        final pageNum = int.tryParse(parts[1]) ?? 0;
        final surahId = int.tryParse(parts[3]) ?? 0;
        final ayahNum = int.tryParse(parts[4]) ?? 0;
        final lineNum = int.tryParse(parts[5]) ?? 0;

        if (pageNum == 0 || lineNum == 0) continue;
        
        // Skip non-verse lines (headers, bismillahs which are usually -1, -2)
        // Except maybe we want to handle them? For now, only actual verses.
        if (ayahNum <= 0) continue; 

        _pageLines.putIfAbsent(pageNum, () => {});
        _pageLines[pageNum]!.putIfAbsent(lineNum, () => []);
        
        // Create a Verse object (simplified)
        // We don't have full text/translation here, but enough for ID
        final verse = Verse(
          id: 0, // Placeholder
          verseKey: '$surahId:$ayahNum',
          textUthmani: '', 
          translation: '',
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

  // Audio Playback for Page (Basic sequential ayah playback)
  // This is a simplified version. Real implementation needs robust playlist management.
  Future<void> playPage(int pageNumber) async {
    if (_isPlaying) {
      await _audioManager.stop();
      _isPlaying = false;
      notifyListeners();
      return; 
    }

    try {
      _isPlaying = true;
      notifyListeners();
      
      final verses = await getVersesForPage(pageNumber);
      for (var verse in verses) {
        if (!_isPlaying) break; // Check if stopped
        await _audioManager.playAyah(verse.surahId, verse.verseNumber);
        
        // Wait for player to finish (very basic sync)
        // Ideally we listen to playerStateStream.completed
        await _audioManager.playerStateStream.firstWhere((state) => 
            state.processingState == ProcessingState.completed || 
            state.processingState == ProcessingState.idle);
      }
    } catch (e) {
      print("Error playing page error: $e");
    } finally {
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> stopAudio() async {
    await _audioManager.stop();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> playAyah(Verse verse) async {
    // Stop any page playback
    _isPlaying = false; // logic shift
    await _audioManager.playAyah(verse.surahId, verse.verseNumber);
    // We don't necessarily track 'isPlaying' for single ayah here unless we want UI feedback
    // extending isPlaying logic is complex, for now just play.
  }
}
