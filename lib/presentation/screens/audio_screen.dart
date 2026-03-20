import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Player')),
      body: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          // ── Empty state ───────────────────────────────────────────────────
          if (!provider.isPlaying && provider.currentSurahName == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 80,
                      color: AppTheme.goldColor.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  Text('No Audio Playing',
                      style: AppTheme.headingStyle
                          .copyWith(color: AppTheme.greyText)),
                  const SizedBox(height: 8),
                  Text('Select a Surah to start listening',
                      style: AppTheme.bodyStyle
                          .copyWith(color: AppTheme.greyText)),
                ],
              ),
            );
          }

          // ── Now-playing view ──────────────────────────────────────────────
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Album art
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.goldColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldColor.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.mosque, size: 90, color: AppTheme.goldColor),
                  ),
                ),
                const SizedBox(height: 36),

                // Surah name
                Text(
                  provider.currentSurahName ?? 'Surah',
                  style: AppTheme.headingStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  provider.currentReciterName,
                  style: AppTheme.subtitleStyle.copyWith(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Verse key
                if (provider.currentVerseKey != null)
                  Text(
                    provider.currentVerseKey!,
                    style: AppTheme.titleStyle
                        .copyWith(color: AppTheme.goldColor),
                  ),

                const SizedBox(height: 32),

                // ── Progress bar ──────────────────────────────────────────
                StreamBuilder<Duration?>(
                  stream: provider.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration =
                        durationSnapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration>(
                      stream: provider.positionStream,
                      builder: (context, positionSnapshot) {
                        final position =
                            positionSnapshot.data ?? Duration.zero;
                        final clampedPosition =
                            position > duration ? duration : position;
                        final progress = duration.inMilliseconds > 0
                            ? clampedPosition.inMilliseconds /
                                duration.inMilliseconds
                            : 0.0;

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppTheme.goldColor,
                                inactiveTrackColor:
                                    AppTheme.goldColor.withOpacity(0.2),
                                thumbColor: AppTheme.goldColor,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16),
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChanged: duration.inMilliseconds > 0
                                    ? (value) {
                                        final newPos = Duration(
                                          milliseconds: (value *
                                                  duration.inMilliseconds)
                                              .round(),
                                        );
                                        provider.seekAudio(newPos);
                                      }
                                    : null,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(clampedPosition),
                                      style: AppTheme.subtitleStyle
                                          .copyWith(fontSize: 12)),
                                  Text(_formatDuration(duration),
                                      style: AppTheme.subtitleStyle
                                          .copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Playback controls ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous verse
                    Tooltip(
                      message: 'Previous verse',
                      child: IconButton(
                        icon: const Icon(Icons.skip_previous_rounded,
                            size: 44, color: AppTheme.blackText),
                        onPressed: provider.skipToPreviousVerse,
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Play / Pause
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.goldColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Tooltip(
                        message: provider.isPlaying ? 'Pause' : 'Play',
                        child: IconButton(
                          iconSize: 48,
                          icon: Icon(
                            provider.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          onPressed: provider.isPlaying
                              ? provider.pauseAudio
                              : provider.resumeAudio,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Next verse
                    Tooltip(
                      message: 'Next verse',
                      child: IconButton(
                        icon: const Icon(Icons.skip_next_rounded,
                            size: 44, color: AppTheme.blackText),
                        onPressed: provider.skipToNextVerse,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
