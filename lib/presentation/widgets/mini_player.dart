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
        final bgColor = isDark ? AppTheme.darkElevated : const Color(0xFF1C1C1E);

        return Container(
          height: 68,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // ── Progress indicator at top ───────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: StreamBuilder<Duration?>(
                    stream: provider.durationStream,
                    builder: (context, durationSnap) {
                      final duration = durationSnap.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: provider.positionStream,
                        builder: (context, positionSnap) {
                          final position = positionSnap.data ?? Duration.zero;
                          final clamped =
                              position > duration ? duration : position;
                          final progress = duration.inMilliseconds > 0
                              ? clamped.inMilliseconds /
                                  duration.inMilliseconds
                              : 0.0;
                          return LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 2.5,
                            backgroundColor:
                                Colors.white.withOpacity(0.12),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.goldColor),
                          );
                        },
                      );
                    },
                  ),
                ),

                // ── Player content ──────────────────────────────────────
                Positioned.fill(
                  child: Row(
                    children: [
                      // Album icon
                      Container(
                        width: 52,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.goldColor.withOpacity(0.15),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.mosque_rounded,
                              color: AppTheme.goldColor, size: 22),
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
                              style: AppTheme.titleStyle.copyWith(
                                  color: Colors.white, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              provider.currentReciterName,
                              style: AppTheme.subtitleStyle
                                  .copyWith(color: Colors.white54, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Play / Pause
                      IconButton(
                        icon: Icon(
                          provider.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppTheme.goldColor,
                          size: 32,
                        ),
                        onPressed: provider.isPlaying
                            ? provider.pauseAudio
                            : provider.resumeAudio,
                        tooltip: provider.isPlaying ? 'Pause' : 'Play',
                      ),

                      // Stop
                      IconButton(
                        icon: const Icon(Icons.stop_rounded,
                            color: Colors.white38, size: 24),
                        onPressed: provider.stopAudio,
                        tooltip: 'Stop',
                      ),
                      const SizedBox(width: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
