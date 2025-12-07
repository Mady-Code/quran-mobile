import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranProvider>(
      builder: (context, provider, child) {
        // Hide if not playing and no surah selected (initial state)
        if (provider.currentSurahName == null) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D), // Dark background for contrast
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Album Art / Icon
              Container(
                width: 64,
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.music_note, color: AppTheme.goldColor),
                ),
              ),
              const SizedBox(width: 12),
              
              // Text Info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.currentSurahName ?? "Select Surah",
                      style: AppTheme.titleStyle.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.currentReciterName,
                      style: AppTheme.subtitleStyle.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Controls
              IconButton(
                icon: Icon(
                  provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: AppTheme.goldColor,
                  size: 40,
                ),
                onPressed: () {
                   if (provider.isPlaying) {
                     provider.stopAudio();
                   } else {
                     // Resume logic is needed in Provider or this button just stops?
                     // Currently Provider only has playAyah and stopAudio.
                     // Stop mostly resets player. Resume depends on AudioService state.
                     // For now, let's assume stop acts as pause/stop.
                     // TODO: Implement Resume in Provider
                     provider.stopAudio(); 
                   }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}
