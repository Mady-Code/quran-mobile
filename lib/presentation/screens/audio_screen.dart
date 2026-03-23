import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/di/injection_container.dart';
import '../widgets/reciter_selection_dialog.dart';
import '../providers/settings_provider.dart';

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppTheme.creamColor;
    final textColor = isDark ? AppTheme.darkText : AppTheme.blackText;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Lecteur Audio',
          style: AppTheme.headingStyle.copyWith(color: textColor, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.text_decrease_rounded, size: 20),
                    onPressed: settings.arabicFontSize > 20
                        ? () => settings.setArabicFontSize(settings.arabicFontSize - 2)
                        : null,
                    tooltip: 'Diminuer la taille',
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_increase_rounded, size: 24),
                    onPressed: settings.arabicFontSize < 60
                        ? () => settings.setArabicFontSize(settings.arabicFontSize + 2)
                        : null,
                    tooltip: 'Augmenter la taille',
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ],
      ),
      drawer: _buildSurahDrawer(context, isDark),
      body: SafeArea(
        child: Consumer<QuranProvider>(
          builder: (context, provider, child) {
            return _buildPlayerView(context, provider, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildSurahDrawer(BuildContext context, bool isDark) {
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Drawer(
      backgroundColor: bgColor,
      child: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.library_music_rounded, color: AppTheme.goldColor, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Choisir une Sourate',
                        style: AppTheme.headingStyle.copyWith(
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: provider.surahs.length,
                    itemBuilder: (context, index) {
                      final surah = provider.surahs[index];
                      final isSelected = provider.currentSurahName == surah.nameSimple;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.goldColor 
                                : AppTheme.goldColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: isSelected && provider.isPlaying
                              ? const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 18)
                              : Text(
                                  '${surah.id}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.goldColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        title: Text(
                          surah.nameSimple,
                          style: AppTheme.headingStyle.copyWith(
                            fontSize: 16,
                            color: isSelected 
                                ? AppTheme.goldColor 
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        subtitle: Text(
                          '${surah.revelationPlace} • ${surah.versesCount} Versets',
                          style: AppTheme.subtitleStyle.copyWith(fontSize: 12),
                        ),
                        trailing: Text(
                          surah.nameArabic,
                          style: AppTheme.arabicText.copyWith(
                            fontSize: 18,
                            color: AppTheme.goldColor,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close Drawer
                          if (!isSelected || !provider.isPlaying) {
                            provider.playSurah(surah.id);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerView(BuildContext context, QuranProvider provider, bool isDark) {
    final textColor = isDark ? AppTheme.darkText : AppTheme.blackText;
    final subtitleColor = isDark ? AppTheme.darkSubtitle : AppTheme.greyText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Surah Title
          Text(
            provider.currentSurahName ?? 'Ouvrez le menu pour choisir',
            style: AppTheme.headingStyle.copyWith(
              fontSize: provider.currentSurahName == null ? 20 : 32,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Reciter Name (Tappable)
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => ReciterSelectionDialog(
                  currentReciterId: provider.currentReciterId,
                  onReciterSelected: (id, name, audioAssets) async {
                    await sl<SettingsProvider>().setReciter(id, name, audioAssets);
                    await sl<AudioService>().switchReciter(id, name, audioAssets);
                  },
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic_rounded, size: 18, color: AppTheme.goldColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    provider.currentReciterName,
                    style: AppTheme.subtitleStyle.copyWith(
                      color: subtitleColor, 
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: subtitleColor),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Premium Verse Display fills remaining space
          Expanded(
            child: (sl<AudioService>().hasSegments && provider.currentVerseKey != null) 
              ? _AudioVerseDisplay(provider: provider, isDark: isDark)
              : _buildFallbackDisplay(provider, isDark),
          ),
          
          const SizedBox(height: 32),
          
          // Progress bar
          _ProgressBar(
            provider: provider,
            isDark: isDark,
            formatDuration: _formatDuration,
          ),
          
          const SizedBox(height: 24),
          
          // Controls
          _Controls(provider: provider, isDark: isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFallbackDisplay(QuranProvider provider, bool isDark) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.goldColor.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mosque_rounded, size: 90, color: AppTheme.goldColor.withOpacity(0.4)),
          const SizedBox(height: 32),
          Text(
            provider.currentSurahName ?? '',
            style: AppTheme.arabicText.copyWith(
              fontSize: 38,
              color: AppTheme.goldColor.withOpacity(0.9),
              shadows: [
                Shadow(
                  color: AppTheme.goldColor.withOpacity(0.3),
                  blurRadius: 10,
                )
              ]
            ),
          ),
          if (provider.currentSurahName != null) ...[
            const SizedBox(height: 16),
            Text(
              'Lecture en cours...',
              style: AppTheme.subtitleStyle.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final QuranProvider provider;
  final bool isDark;
  final String Function(Duration) formatDuration;

  const _ProgressBar({
    required this.provider,
    required this.isDark,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: provider.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: provider.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final clamped = position > duration ? duration : position;
            final progress = duration.inMilliseconds > 0
                ? clamped.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.goldColor,
                    inactiveTrackColor: AppTheme.goldColor.withOpacity(0.2),
                    thumbColor: AppTheme.goldColor,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: duration.inMilliseconds > 0
                        ? (value) {
                            final newPos = Duration(
                              milliseconds: (value * duration.inMilliseconds).round(),
                            );
                            provider.seekAudio(newPos);
                          }
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(clamped),
                        style: AppTheme.labelStyle.copyWith(
                          color: isDark ? AppTheme.darkSubtitle : AppTheme.greyText,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        formatDuration(duration),
                        style: AppTheme.labelStyle.copyWith(
                          color: isDark ? AppTheme.darkSubtitle : AppTheme.greyText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  final QuranProvider provider;
  final bool isDark;

  const _Controls({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? AppTheme.darkText : AppTheme.blackText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Speed Control
        StreamBuilder<double>(
          stream: provider.speedStream,
          builder: (context, snapshot) {
            final speed = snapshot.data ?? 1.0;
            return PopupMenuButton<double>(
              initialValue: speed,
              onSelected: provider.setSpeed,
              color: isDark ? AppTheme.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              itemBuilder: (context) => [
                0.5, 0.75, 1.0, 1.25, 1.5, 2.0
              ].map((s) => PopupMenuItem(
                value: s,
                child: Text('${s}x', style: AppTheme.headingStyle.copyWith(
                  color: s == speed ? AppTheme.goldColor : (isDark ? Colors.white : Colors.black),
                  fontSize: 14,
                )),
              )).toList(),
              offset: const Offset(0, -220),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.goldColor.withOpacity(0.2)),
                ),
                child: Text(
                  '${speed}x', 
                  style: AppTheme.headingStyle.copyWith(color: AppTheme.goldColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        ),
        
        // Previous
        _ControlButton(
          icon: Icons.skip_previous_rounded,
          size: 32,
          color: iconColor,
          onTap: provider.skipToPreviousVerse,
          tooltip: 'Verset précédent',
        ),
        
        // Play/Pause
        GestureDetector(
          onTap: provider.isPlaying ? provider.pauseAudio : provider.resumeAudio,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.goldColor,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldColor.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        
        // Next
        _ControlButton(
          icon: Icons.skip_next_rounded,
          size: 32,
          color: iconColor,
          onTap: provider.skipToNextVerse,
          tooltip: 'Verset suivant',
        ),

        // Placeholder to balance the speed button
        const SizedBox(width: 50),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}

class _AudioVerseDisplay extends StatelessWidget {
  final QuranProvider provider;
  final bool isDark;

  const _AudioVerseDisplay({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final verse = provider.currentVerse;
    if (verse == null || verse.textUthmani.trim().isEmpty) return const SizedBox.shrink();
    
    final words = verse.textUthmani.trim().split(RegExp(r'\s+'));
    final segments = sl<AudioService>().getSegmentsForVerse(verse.verseKey ?? '') ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
            : [Colors.white, const Color(0xFFFDFBF7)],
        ),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(isDark ? 0.2 : 0.4), 
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Small verse indicator at the top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.goldColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Verset ${verse.verseKey}',
              style: AppTheme.headingStyle.copyWith(
                color: AppTheme.goldColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Scrollable Text
          Expanded(
            child: StreamBuilder<Duration>(
              stream: provider.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data?.inMilliseconds ?? 0;
                
                int activeIndex = -1;
                for (final segment in segments) {
                  if (position >= segment.startMs && position <= segment.endMs) {
                    activeIndex = segment.index;
                    break;
                  }
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      textDirection: TextDirection.rtl,
                      spacing: 12,
                      runSpacing: 20,
                      children: List.generate(words.length, (index) {
                        final isHighlighted = index == activeIndex;
                        final baseSize = sl<SettingsProvider>().arabicFontSize;
                        return AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: AppTheme.arabicText.copyWith(
                            fontSize: isHighlighted ? baseSize + 10 : baseSize,
                            height: 1.8,
                            color: isHighlighted 
                                ? AppTheme.goldColor 
                                : (isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black87.withValues(alpha: 0.7)),
                            shadows: isHighlighted ? [
                              Shadow(
                                color: AppTheme.goldColor.withValues(alpha: 0.5),
                                blurRadius: 15,
                              ),
                              Shadow(
                                color: AppTheme.goldColor.withValues(alpha: 0.2),
                                blurRadius: 30,
                              ),
                            ] : null,
                          ),
                          child: Text(words[index]),
                        );
                      }),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
