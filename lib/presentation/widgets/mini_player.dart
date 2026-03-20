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
        if (provider.currentSurahName == null) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? AppTheme.darkCard : AppTheme.blackText;

        return Container(
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
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
              // Album art thumbnail
              Container(
                width: 64,
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withOpacity(0.15),
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

              // Track info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.currentSurahName!,
                      style: AppTheme.titleStyle
                          .copyWith(color: Colors.white, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      provider.currentReciterName,
                      style: AppTheme.subtitleStyle
                          .copyWith(color: Colors.white60, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Play / Pause
              Tooltip(
                message: provider.isPlaying ? 'Pause' : 'Play',
                child: IconButton(
                  icon: Icon(
                    provider.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: AppTheme.goldColor,
                    size: 40,
                  ),
                  onPressed: provider.isPlaying
                      ? provider.pauseAudio
                      : provider.resumeAudio,
                ),
              ),

              // Stop
              Tooltip(
                message: 'Stop',
                child: IconButton(
                  icon: const Icon(Icons.stop_circle_outlined,
                      color: Colors.white54, size: 32),
                  onPressed: provider.stopAudio,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        );
      },
    );
  }
}
