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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTap: () {
                  onTap?.call();
                },
                onLongPressStart: (details) {
                  _handleLongPress(context, details, constraints, provider);
                },
                child: Center(
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
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleLongPress(BuildContext context, LongPressStartDetails details, BoxConstraints constraints, QuranProvider provider) {
    // 1. Calculate Image Rendered Rect (As BoxFit.contain is used)
    final double screenW = constraints.maxWidth;
    final double screenH = constraints.maxHeight;
    final double screenRatio = screenW / screenH;
    
    // Standard Madinah Page Ratio (approx)
    const double imageRatio = 0.635; // 604/950 approx or 1024/1600

    double imgW, imgH;
    double offsetX = 0, offsetY = 0;

    if (screenRatio > imageRatio) {
      // Screen is wider -> Limited by Height
      imgH = screenH;
      imgW = imgH * imageRatio;
      offsetX = (screenW - imgW) / 2;
    } else {
      // Screen is taller -> Limited by Width
      imgW = screenW;
      imgH = imgW / imageRatio;
      offsetY = (screenH - imgH) / 2;
    }

    // 2. Map Tap to Line
    final double localY = details.localPosition.dy;
    
    // Check if tap is within image vertical area
    if (localY < offsetY || localY > offsetY + imgH) {
      return; 
    }

    final double relativeY = localY - offsetY;
    final double pctY = relativeY / imgH;

    // Simple 15 lines grid:
    final int line = (pctY * 15).floor() + 1; // 1-based

    if (line < 1 || line > 15) return;

    // 3. Get Verses
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
