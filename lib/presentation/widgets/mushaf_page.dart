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

        final surahs = context.read<QuranProvider>().surahs;
        
        // Determine the primary Surah for the page header (based on the first verse)
        final firstVerse = verses.first;
        final firstSurahId = int.parse(firstVerse.verseKey.split(':')[0]);
        final headerSurah = surahs.firstWhere(
          (s) => s.id == firstSurahId,
          orElse: () => surahs.first,
        );

        // Group verses layout
        final Map<int, List<Verse>> versesBySurah = {};
        for (var verse in verses) {
          final chapterId = int.parse(verse.verseKey.split(':')[0]);
          if (!versesBySurah.containsKey(chapterId)) {
            versesBySurah[chapterId] = [];
          }
          versesBySurah[chapterId]!.add(verse);
        }

        return Container(
          color: const Color(0xFFEEEBE0), // Background behind the page
          alignment: Alignment.center,
          // Removed vertical padding to maximize screen usage
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: 420,  // Narrower to fit phone aspect ratio better
              height: 880, // Taller
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF0), // Page detail color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative Frame
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(8), // Reduced outer margin
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF4A4A4A),
                          width: 2,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2), // Reduced spacing
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFD4AF37),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Reduced content padding
                    child: Column(
                      children: [
                        // Header
                        _buildPageHeader(headerSurah, pageNumber),
                        const SizedBox(height: 4), // Reduced spacing
                        
                        // Verses Body
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                            children: [
                               // Use a ListView or Column? Column is fine if we fit.
                               // To mimic 15 lines, we want the text to expand.
                              ...versesBySurah.entries.map((entry) {
                                final chapterId = entry.key;
                                final chapterVerses = entry.value;
                                final surah = surahs.firstWhere(
                                  (s) => s.id == chapterId,
                                  orElse: () => surahs.first,
                                );
                                final isFirstVerseInSurah = chapterVerses.any((v) => v.verseKey.endsWith(':1'));

                                return Expanded( // Allow specific surah block to take space
                                  child: Column(
                                    children: [
                                      if (isFirstVerseInSurah) ...[
                                        const SizedBox(height: 4),
                                        _buildSurahBanner(surah),
                                        if (surah.id != 1 && surah.id != 9) _buildBismillah(),
                                      ],
                                      Expanded(
                                        child: _buildVersesText(chapterVerses),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        // Footer
                        const SizedBox(height: 4),
                        Text(
                          _toArabicNumber(pageNumber),
                          style: const TextStyle(
                            fontFamily: 'KFGQPC Uthmanic Script HAFS',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageHeader(Surah surah, int pageNumber) {
    return SizedBox(
      height: 24, // Reduced height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الجزء ${_toArabicNumber(1)}', 
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'KFGQPC Uthmanic Script HAFS',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'سُورَةُ ${surah.nameArabic}',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'KFGQPC Uthmanic Script HAFS',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahBanner(Surah surah) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE0),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1),
      ),
      child: Center(
        child: Text(
          'سُورَةُ ${surah.nameArabic}',
          style: const TextStyle(
            fontFamily: 'KFGQPC Uthmanic Script HAFS',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildBismillah() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
        style: const TextStyle(
          fontFamily: 'KFGQPC Uthmanic Script HAFS',
          fontSize: 15, // Slightly smaller to fit
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVersesText(List<Verse> verses) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
                    fontSize: 22, // Increased font size
                    color: Colors.black,
                    height: 1.7, // Adjusted line height
                  ),
                ),
                TextSpan(
                  text: '﴿$arabicNum﴾ ',
                  style: const TextStyle(
                    fontFamily: 'KFGQPC Uthmanic Script HAFS',
                    fontSize: 18,
                    color: Color(0xFFD4AF37),
                    height: 1.7,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
