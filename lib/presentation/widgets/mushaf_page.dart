import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../features/quran/domain/entities/verse.dart';
import '../../features/quran/domain/entities/surah.dart';
import '../providers/quran_provider.dart';

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
        
        // Negative filter matrix
        const ColorFilter nightFilter = ColorFilter.matrix(<double>[
          -1,  0,  0, 0, 255,
           0, -1,  0, 0, 255,
           0,  0, -1, 0, 255,
           0,  0,  0, 1,   0,
        ]);

        return Container(
          color: isNightMode ? const Color(0xFF202020) : const Color(0xFFFAF8F3),
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1024 / 1656, // actual asset ratio
                child: Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        onTap?.call();
                      },
                      onLongPressStart: (details) {
                        // Get the height of the RenderBox (which is the Image height)
                        final RenderBox box = context.findRenderObject() as RenderBox;
                        final double imageHeight = box.size.height;
                        
                        _handleLongPress(context, details, imageHeight, provider);
                      },
                      child: ColorFiltered(
                        colorFilter: isNightMode ? nightFilter : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey));
                          },
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLongPress(BuildContext context, LongPressStartDetails details, double imageHeight, QuranProvider provider) {
    // 1. Get local Y coordinate on the image
    final double localY = details.localPosition.dy;
    
    // Check bounds just in case (though GestureDetector shouldn't fire outside)
    if (localY < 0 || localY > imageHeight) {
      return; 
    }

    final double pctY = localY / imageHeight;

    // Simple 15 lines grid:
    final int line = (pctY * 15).floor() + 1; // 1-based

    if (line < 1 || line > 15) return;

    // 2. Get Verses
    final verses = provider.getVersesForLine(pageNumber, line);

    if (verses.isNotEmpty) {
      HapticFeedback.mediumImpact(); // Add haptic feedback for long press
      _showVerseOptions(context, verses, provider);
    } 
  }

  void _showVerseOptions(BuildContext context, List<Verse> verses, QuranProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: provider.isNightMode ? const Color(0xFF303030) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Sélectionnez un Verset',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: provider.isNightMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const Divider(),
              ...verses.map((verse) {
                 final surahName = provider.surahs.firstWhere((s) => s.id == verse.surahId, orElse: () => Surah(id:0, nameSimple: '?', nameArabic: '?', versesCount: 0, revelationPlace: '', pages: [])).nameSimple;
                 return ListTile(
                  title: Text(
                    '$surahName ${verse.verseNumber}',
                    style: TextStyle(color: provider.isNightMode ? Colors.white : Colors.black),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.amber),
                        onPressed: () {
                           Navigator.pop(context);
                           provider.playAyah(verse);
                        },  
                      ),
                       IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: () {
                           Navigator.pop(context);
                           // Copy text (needs text data)
                        },  
                      ),
                    ],
                  ),
                  onTap: () {
                     // Action?
                     Navigator.pop(context);
                  },
                 );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
