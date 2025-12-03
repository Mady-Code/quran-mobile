import 'package:flutter/material.dart';
import '../../data/models/surah.dart';
import '../../data/models/verse.dart';
import '../../data/repositories/quran_repository.dart';

class QuranProvider with ChangeNotifier {
  final QuranRepository _repository = QuranRepository();
  
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
}
