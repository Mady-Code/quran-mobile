import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../features/quran/domain/entities/verse.dart';
import '../../features/quran/domain/entities/surah.dart';
import '../providers/quran_provider.dart';
import '../../core/theme/app_theme.dart';

class MushafPage extends StatelessWidget {
  final int pageNumber;
  final VoidCallback? onTap;

  const MushafPage({
    super.key,
    required this.pageNumber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranProvider>(
      builder: (context, provider, child) {
        final imagePath = provider.getPageAssetPath(pageNumber);
        final isNightMode = provider.isNightMode;

        const ColorFilter nightFilter = ColorFilter.matrix(<double>[
          -1, 0, 0, 0, 255,
           0,-1, 0, 0, 255,
           0, 0,-1, 0, 255,
           0, 0, 0, 1,   0,
        ]);

        return Container(
          color: isNightMode
              ? const Color(0xFF202020)
              : const Color(0xFFFAF8F3),
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: SizedBox.expand(
              child: Builder(
                builder: (context) => GestureDetector(
                  onTap: onTap,
                  onLongPressStart: (details) {
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    _handleLongPress(
                        context, details, box.size.height, provider);
                  },
                  child: ColorFiltered(
                    colorFilter: isNightMode
                        ? nightFilter
                        : const ColorFilter.mode(
                            Colors.transparent, BlendMode.dst),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 25.0),
                      child: SvgPicture.asset(
                        imagePath,
                        fit: BoxFit.fill, // Étire l'image pour remplir l'écran (sans marge, sans débordement)
                        placeholderBuilder: (_) => const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLongPress(
    BuildContext context,
    LongPressStartDetails details,
    double imageHeight,
    QuranProvider provider,
  ) {
    final double localY = details.localPosition.dy;
    if (localY < 0 || localY > imageHeight) return;

    final int line = (localY / imageHeight * 15).floor() + 1;
    if (line < 1 || line > 15) return;

    final verses = provider.getVersesForLine(pageNumber, line);
    if (verses.isNotEmpty) {
      HapticFeedback.mediumImpact();
      _showVerseOptions(context, verses, provider);
    }
  }

  void _showVerseOptions(
    BuildContext context,
    List<Verse> verses,
    QuranProvider provider,
  ) {
    final isNightMode = provider.isNightMode;
    final sheetBg = isNightMode ? const Color(0xFF303030) : Colors.white;
    final textColor = isNightMode ? Colors.white : AppTheme.blackText;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select a verse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const Divider(height: 1),
            ...verses.map((verse) {
              final surahName = provider.surahs
                  .firstWhere(
                    (s) => s.id == verse.surahId,
                    orElse: () => const Surah(
                        id: 0,
                        nameSimple: '?',
                        nameArabic: '?',
                        versesCount: 0,
                        revelationPlace: '',
                        pages: []),
                  )
                  .nameSimple;

              return ListTile(
                title: Text(
                  '$surahName ${verse.verseNumber}',
                  style: TextStyle(color: textColor),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'Play verse',
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow,
                            color: AppTheme.goldColor),
                        onPressed: () {
                          Navigator.pop(context);
                          provider.playAyah(verse);
                        },
                      ),
                    ),
                    Tooltip(
                      message: 'Copy verse key',
                      child: IconButton(
                        icon:
                            Icon(Icons.copy, color: Colors.grey.shade400),
                        onPressed: () {
                          Navigator.pop(context);
                          Clipboard.setData(ClipboardData(
                              text: verse.verseKey ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Verse ${verse.verseKey} copied to clipboard'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                onTap: () => Navigator.pop(context),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
