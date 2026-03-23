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
      ),
      drawer: _buildSurahDrawer(context, isDark),
      body: SafeArea(
        child: Consumer<QuranProvider>(
          builder: (context, provider, child) {
            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildPlayerView(context, provider, isDark),
              ),
            );
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
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art
          _AlbumArt(isPlaying: provider.isPlaying, size: 280),
          const SizedBox(height: 48),
          
          // Title
          Text(
            provider.currentSurahName ?? 'Ouvrez le menu pour choisir',
            style: AppTheme.headingStyle.copyWith(
              fontSize: provider.currentSurahName == null ? 20 : 28,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Reciter Name
          Row(
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
            ],
          ),
          
          if (provider.currentVerseKey != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.goldColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.goldColor.withOpacity(0.3)),
              ),
              child: Text(
                'Verset ${provider.currentVerseKey}',
                style: TextStyle(
                  color: AppTheme.goldColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 48),
          
          // Progress bar
          _ProgressBar(
            provider: provider,
            isDark: isDark,
            formatDuration: _formatDuration,
          ),
          
          const SizedBox(height: 32),
          
          // Controls
          _Controls(provider: provider, isDark: isDark),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _AlbumArt extends StatefulWidget {
  final bool isPlaying;
  final double size;
  
  const _AlbumArt({required this.isPlaying, this.size = 280});

  @override
  State<_AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<_AlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (widget.isPlaying) _rotateController.repeat();
  }

  @override
  void didUpdateWidget(_AlbumArt old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_rotateController.isAnimating) {
      _rotateController.repeat();
    } else if (!widget.isPlaying && _rotateController.isAnimating) {
      _rotateController.stop();
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotateController,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.3),
            colors: [Color(0xFF3D8A57), AppTheme.darkGreen, Color(0xFF0F2D1C)],
          ),
          border: Border.all(color: AppTheme.goldColor.withOpacity(0.6), width: 3),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldColor.withOpacity(0.25),
              blurRadius: 30,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative rings
            Container(
              width: widget.size * 0.75,
              height: widget.size * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.goldColor.withOpacity(0.2), width: 1.5),
              ),
            ),
            Container(
              width: widget.size * 0.5,
              height: widget.size * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.goldColor.withOpacity(0.15), width: 1.5),
              ),
            ),
            // Center icon
            Container(
              width: widget.size * 0.3,
              height: widget.size * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.4),
              ),
              child: Icon(Icons.mosque_rounded, size: widget.size * 0.15, color: AppTheme.goldColor),
            ),
          ],
        ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.skip_previous_rounded,
          size: 36,
          color: iconColor,
          onTap: provider.skipToPreviousVerse,
          tooltip: 'Verset précédent',
        ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: provider.isPlaying ? provider.pauseAudio : provider.resumeAudio,
          child: Container(
            width: 80,
            height: 80,
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
              size: 42,
            ),
          ),
        ),
        const SizedBox(width: 32),
        _ControlButton(
          icon: Icons.skip_next_rounded,
          size: 36,
          color: iconColor,
          onTap: provider.skipToNextVerse,
          tooltip: 'Verset suivant',
        ),
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
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}
