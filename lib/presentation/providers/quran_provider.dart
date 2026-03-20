import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../features/quran/domain/entities/surah.dart';
import '../../features/quran/domain/entities/verse.dart';
import '../../features/quran/domain/repositories/quran_repository.dart';
import '../../core/services/audio_service.dart';
import '../../core/api/qul_service.dart';
import '../../core/di/injection_container.dart';
import 'settings_provider.dart';
import '../../features/quran/domain/entities/mushaf_type.dart';

class QuranProvider with ChangeNotifier {
  final QuranRepository _repository = sl<QuranRepository>();
  final AudioService _audioService = sl<AudioService>();
  final QulService _qulService = QulService();

  MushafType get mushafType => sl<SettingsProvider>().mushafType;

  // ── Night mode delegated to SettingsProvider ──────────────────────────────
  bool get isNightMode => sl<SettingsProvider>().nightMode;
  Future<void> toggleNightMode() => sl<SettingsProvider>().toggleNightMode();

  // ── Current verse tracking ────────────────────────────────────────────────
  String? _currentVerseKey;
  String? get currentVerseKey => _currentVerseKey;

  Verse? _currentVerse;
  Verse? get currentVerse => _currentVerse;

  QuranProvider() {
    _audioService.currentVerseStream.listen((key) {
      if (_currentVerseKey != key) {
        _currentVerseKey = key;
        notifyListeners();
      }
    });

    _audioService.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    sl<SettingsProvider>().addListener(notifyListeners);
  }

  String getPageAssetPath(int pageNumber) {
    final paddedNum = pageNumber.toString().padLeft(3, '0');
    return 'assets/images/Qiraat/${mushafType.name}/$paddedNum.svg';
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

  final Map<int, List<Verse>> _pageVersesCache = {};

  Future<List<Verse>> getVersesForPage(int pageNumber) async {
    if (_pageVersesCache.containsKey(pageNumber)) {
      return _pageVersesCache[pageNumber]!;
    }
    return [];
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

  // ── Audio state ───────────────────────────────────────────────────────────
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String? _currentSurahName;
  String? get currentSurahName => _currentSurahName;

  String get currentReciterId => sl<SettingsProvider>().reciterId;
  String get currentReciterName => sl<SettingsProvider>().reciterName;

  // ── Audio streams (forwarded from AudioService) ───────────────────────────
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;

  // ── Audio control methods ─────────────────────────────────────────────────
  Future<void> playAyah(Verse verse) async {
    try {
      _currentVerse = verse;
      final reciterId = sl<SettingsProvider>().reciterId;
      final audioUrl = _qulService.getAyahAudioUrl(reciterId, verse.surahId, verse.verseNumber);

      final surah = _surahs.firstWhere(
        (s) => s.id == verse.surahId,
        orElse: () => const Surah(id: 0, nameSimple: '', nameArabic: '', versesCount: 0, revelationPlace: '', pages: []),
      );
      if (surah.id != 0) {
        _currentSurahName = surah.nameSimple;
        notifyListeners();
      }

      await _audioService.playAudioUrl(audioUrl);
    } catch (e) {
      print('Error playing ayah: $e');
    }
  }

  Future<void> pauseAudio() async {
    await _audioService.pause();
  }

  Future<void> resumeAudio() async {
    await _audioService.play();
  }

  Future<void> stopAudio() async {
    await _audioService.stop();
  }

  Future<void> seekAudio(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> skipToNextVerse() async {
    if (_currentVerse == null) return;
    try {
      final verses = await getVersesForSurah(_currentVerse!.surahId);
      final idx = verses.indexWhere((v) => v.verseNumber == _currentVerse!.verseNumber);
      if (idx >= 0 && idx < verses.length - 1) {
        await playAyah(verses[idx + 1]);
      } else if (_currentVerse!.surahId < 114) {
        // Move to the first verse of the next surah
        final nextVerses = await getVersesForSurah(_currentVerse!.surahId + 1);
        if (nextVerses.isNotEmpty) await playAyah(nextVerses.first);
      }
    } catch (e) {
      print('Error skipping to next verse: $e');
    }
  }

  Future<void> skipToPreviousVerse() async {
    if (_currentVerse == null) return;
    try {
      final verses = await getVersesForSurah(_currentVerse!.surahId);
      final idx = verses.indexWhere((v) => v.verseNumber == _currentVerse!.verseNumber);
      if (idx > 0) {
        await playAyah(verses[idx - 1]);
      } else if (_currentVerse!.surahId > 1) {
        final prevVerses = await getVersesForSurah(_currentVerse!.surahId - 1);
        if (prevVerses.isNotEmpty) await playAyah(prevVerses.last);
      }
    } catch (e) {
      print('Error skipping to previous verse: $e');
    }
  }

  // ── Bookmarks ────────────────────────────────────────────────────────────
  List<int> _bookmarks = [];
  List<int> get bookmarks => _bookmarks;

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

  bool isPageBookmarked(int pageNumber) => _bookmarks.contains(pageNumber);

  // ── Interaction data (line-level verse mapping for Mushaf long-press) ─────
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
          surahId: surahId,
          verseNumber: ayahNum,
          verseKey: '$surahId:$ayahNum',
          textUthmani: '',
          pageNumber: pageNum,
        );

        _pageLines[pageNum]![lineNum]!.add(verse);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading interaction data: $e');
    }
  }

  List<Verse> getVersesForLine(int page, int line) {
    if (_pageLines.containsKey(page) && _pageLines[page]!.containsKey(line)) {
      return _pageLines[page]![line]!;
    }
    return [];
  }

  Future<void> playPage(int pageNumber) async {
    if (_pageLines.containsKey(pageNumber)) {
      final lines = _pageLines[pageNumber]!;
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
    print('No interaction data found for page $pageNumber');
  }
}
