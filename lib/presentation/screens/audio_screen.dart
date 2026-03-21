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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF0F0F0F)]
                : [AppTheme.creamColor, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Consumer<QuranProvider>(
            builder: (context, provider, child) {
              // ── Empty state ─────────────────────────────────────────────
              if (!provider.isPlaying && provider.currentSurahName == null) {
                return _buildEmptyState(context, isDark);
              }
              return _buildPlayerView(context, provider, isDark);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Column(
      children: [
        // App bar area
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Audio Player',
                style: AppTheme.headingStyle.copyWith(
                  color: isDark ? AppTheme.darkText : AppTheme.blackText,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.goldColor.withOpacity(0.2),
                        AppTheme.goldColor.withOpacity(0.04),
                      ],
                    ),
                    border: Border.all(
                        color: AppTheme.goldColor.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.music_note_rounded,
                      size: 52, color: AppTheme.goldColor),
                ),
                const SizedBox(height: 28),
                Text(
                  'No Audio Playing',
                  style: AppTheme.headingStyle.copyWith(
                    fontSize: 20,
                    color: isDark ? AppTheme.darkText : AppTheme.blackText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a surah to start listening',
                  style: AppTheme.subtitleStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  icon: const Icon(Icons.library_music_outlined,
                      color: AppTheme.goldColor),
                  label: Text(
                    'Browse Surahs',
                    style: AppTheme.bodyStyle
                        .copyWith(color: AppTheme.goldColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.goldColor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerView(
      BuildContext context, QuranProvider provider, bool isDark) {
    final textColor = isDark ? AppTheme.darkText : AppTheme.blackText;
    final subtitleColor = isDark ? AppTheme.darkSubtitle : AppTheme.greyText;

    return Column(
      children: [
        // ── AppBar area ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Now Playing',
                  style: AppTheme.headingStyle
                      .copyWith(color: textColor, fontSize: 18)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.graphic_eq_rounded,
                        color: AppTheme.goldColor, size: 16),
                    const SizedBox(width: 4),
                    Text('Live',
                        style: AppTheme.labelStyle.copyWith(
                            color: AppTheme.goldColor,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── Album art ─────────────────────────────────────────────
                _AlbumArt(isPlaying: provider.isPlaying),
                const SizedBox(height: 36),

                // ── Track info ────────────────────────────────────────────
                Text(
                  provider.currentSurahName ?? 'Surah',
                  style: AppTheme.headingStyle.copyWith(
                    fontSize: 24,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_rounded,
                        size: 14, color: AppTheme.goldColor),
                    const SizedBox(width: 4),
                    Text(
                      provider.currentReciterName,
                      style: AppTheme.subtitleStyle
                          .copyWith(color: subtitleColor, fontSize: 14),
                    ),
                  ],
                ),
                if (provider.currentVerseKey != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.goldColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.goldColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Verse ${provider.currentVerseKey}',
                      style: AppTheme.labelStyle.copyWith(
                        color: AppTheme.goldColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 36),

                // ── Progress bar ──────────────────────────────────────────
                _ProgressBar(
                  provider: provider,
                  isDark: isDark,
                  formatDuration: _formatDuration,
                ),
                const SizedBox(height: 32),

                // ── Controls ──────────────────────────────────────────────
                _Controls(provider: provider, isDark: isDark),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AlbumArt extends StatefulWidget {
  final bool isPlaying;
  const _AlbumArt({required this.isPlaying});

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
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.3),
            colors: [
              Color(0xFF3D8A57),
              AppTheme.darkGreen,
              Color(0xFF0F2D1C),
            ],
          ),
          border: Border.all(
            color: AppTheme.goldColor.withOpacity(0.6),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldColor.withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative rings
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.goldColor.withOpacity(0.2), width: 1),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.goldColor.withOpacity(0.15), width: 1),
              ),
            ),
            // Center icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.4),
              ),
              child: const Icon(Icons.mosque_rounded,
                  size: 30, color: AppTheme.goldColor),
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
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 18),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: duration.inMilliseconds > 0
                        ? (value) {
                            final newPos = Duration(
                              milliseconds:
                                  (value * duration.inMilliseconds).round(),
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
                          color: isDark
                              ? AppTheme.darkSubtitle
                              : AppTheme.greyText,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        formatDuration(duration),
                        style: AppTheme.labelStyle.copyWith(
                          color: isDark
                              ? AppTheme.darkSubtitle
                              : AppTheme.greyText,
                          fontSize: 12,
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
        // Previous verse
        _ControlButton(
          icon: Icons.skip_previous_rounded,
          size: 32,
          color: iconColor,
          onTap: provider.skipToPreviousVerse,
          tooltip: 'Previous verse',
        ),
        const SizedBox(width: 20),

        // Play / Pause (primary)
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
                  color: AppTheme.goldColor.withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              provider.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Next verse
        _ControlButton(
          icon: Icons.skip_next_rounded,
          size: 32,
          color: iconColor,
          onTap: provider.skipToNextVerse,
          tooltip: 'Next verse',
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
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}
