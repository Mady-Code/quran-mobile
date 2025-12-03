import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/verse.dart';
import '../providers/quran_provider.dart';

class MushafPage extends StatelessWidget {
  final int pageNumber;

  const MushafPage({
    super.key,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Format page number to 3 digits (e.g., 001, 012, 123)
    final pageId = pageNumber.toString().padLeft(3, '0');
    final imagePath = 'assets/images/pages/page$pageId.png';

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

        return Center(
          child: AspectRatio(
            aspectRatio: 0.65, // Standard Mushaf aspect ratio
            child: Stack(
              children: [
                // Background: Mushaf page image
                Positioned.fill(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
                // Foreground: Transparent selectable text overlay
                Positioned.fill(
                  child: _buildTextOverlay(verses),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextOverlay(List<Verse> verses) {
    if (verses.isEmpty) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(40.0), // Approximate margin from image
        child: SelectableText.rich(
          TextSpan(
            children: verses.map((verse) {
              return TextSpan(
                text: '${verse.textUthmani} ۝${verse.verseKey.split(':')[1]} ',
                style: const TextStyle(
                  fontFamily: 'KFGQPC Uthmanic Script HAFS',
                  fontSize: 20,
                  color: Colors.transparent, // Invisible but selectable
                  height: 2.0,
                ),
              );
            }).toList(),
          ),
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontFamily: 'KFGQPC Uthmanic Script HAFS',
          ),
        ),
      ),
    );
  }
}
