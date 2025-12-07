import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
        backgroundColor: AppTheme.creamColor,
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          if (!provider.isPlaying && provider.currentSurahName == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.music_note, size: 80, color: AppTheme.goldColor.withOpacity(0.5)),
                   const SizedBox(height: 20),
                   Text(
                    'No Audio Playing',
                    style: AppTheme.headingStyle.copyWith(color: AppTheme.greyText),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Select a Surah to start listening',
                    style: AppTheme.bodyStyle.copyWith(color: AppTheme.greyText),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Art
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.goldColor, width: 2),
                  ),
                  child: Center(
                    child: Icon(Icons.mosque, size: 100, color: AppTheme.goldColor),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Info
                Text(
                  provider.currentSurahName ?? "Surah",
                  style: AppTheme.headingStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.currentReciterName,
                  style: AppTheme.subtitleStyle.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                // Verse highlight
                Text(
                  provider.currentVerseKey ?? "-",
                  style: AppTheme.titleStyle.copyWith(color: AppTheme.goldColor),
                ),
                
                const SizedBox(height: 40),
                
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 48, color: AppTheme.blackText),
                        onPressed: () {}, // TODO: Prev Verse
                    ),
                    const SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.goldColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: IconButton(
                        iconSize: 48,
                        icon: Icon(
                          provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                           if (provider.isPlaying) {
                             provider.stopAudio();
                           } else {
                             // Resume logic or replay?
                             // provider.resume? (Need to implement)
                           }
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 48, color: AppTheme.blackText),
                        onPressed: () {}, // TODO: Next Verse
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
