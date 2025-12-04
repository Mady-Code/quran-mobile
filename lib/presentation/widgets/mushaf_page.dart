import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/verse.dart';
import '../../data/models/surah.dart';
import '../providers/quran_provider.dart';

class MushafPage extends StatelessWidget {
  final int pageNumber;

  const MushafPage({
    super.key,
    required this.pageNumber,
  });

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicDigits[int.parse(digit)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Verse>>(
      future: context.read<QuranProvider>().getVersesForPage(pageNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFD4AF37),
            ),
          );
        }

        final verses = snapshot.data ?? [];
        if (verses.isEmpty) {
          return const Center(child: Text('No verses found'));
        }

        // Group verses by Surah
        final Map<int, List<Verse>> versesBySurah = {};
        for (var verse in verses) {
          final chapterId = int.parse(verse.verseKey.split(':')[0]);
          if (!versesBySurah.containsKey(chapterId)) {
            versesBySurah[chapterId] = [];
          }
          versesBySurah[chapterId]!.add(verse);
        }

        final surahs = context.read<QuranProvider>().surahs;

        return Container(
          color: const Color(0xFFF5F1E8), // Beige/cream background
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5), // Lighter inner background
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Build content for each surah on this page
                  ...versesBySurah.entries.map((entry) {
                    final chapterId = entry.key;
                    final chapterVerses = entry.value;
                    final surah = surahs.firstWhere(
                      (s) => s.id == chapterId,
                      orElse: () => surahs.first,
                    );

                    final isFirstVerse = chapterVerses.any((v) => v.verseKey.endsWith(':1'));

                    return Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isFirstVerse) ...[
                            _buildSurahHeader(surah),
                            if (surah.id != 1 && surah.id != 9) _buildBismillah(),
                          ],
                          Expanded(
                            child: _buildVersesText(chapterVerses),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahHeader(Surah surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          surah.nameArabic,
          style: const TextStyle(
            fontFamily: 'KFGQPC Uthmanic Script HAFS',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildBismillah() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
        style: const TextStyle(
          fontFamily: 'KFGQPC Uthmanic Script HAFS',
          fontSize: 18,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVersesText(List<Verse> verses) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: SelectableText.rich(
          TextSpan(
            children: verses.map((verse) {
              final verseNum = int.parse(verse.verseKey.split(':')[1]);
              final arabicNum = _toArabicNumber(verseNum);
              
              return TextSpan(
                children: [
                  TextSpan(
                    text: '${verse.textUthmani} ',
                    style: const TextStyle(
                      fontFamily: 'KFGQPC Uthmanic Script HAFS',
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.8,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: '۝$arabicNum ',
                    style: const TextStyle(
                      fontFamily: 'KFGQPC Uthmanic Script HAFS',
                      fontSize: 16,
                      color: Color(0xFFD4AF37),
                      height: 1.8,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
