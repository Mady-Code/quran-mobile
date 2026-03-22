import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';
import '../widgets/mushaf_page.dart';
import '../widgets/verse_search_delegate.dart';
import '../../features/quran/domain/entities/verse.dart';

class MushafScreen extends StatefulWidget {
  final int? startPage;

  const MushafScreen({super.key, this.startPage});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late PageController _pageController;
  late int _currentPage;
  bool _showOverlay = false;

  static const int _totalPages = 604;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _currentPage = widget.startPage ?? 1;
    _pageController = PageController(initialPage: _currentPage - 1);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  void _toggleOverlay() => setState(() => _showOverlay = !_showOverlay);

  void _openSearch() async {
    final result = await showSearch<Verse?>(
      context: context,
      delegate: VerseSearchDelegate(),
    );
    if (result != null && result.pageNumber != null) {
      setState(() => _currentPage = result.pageNumber!);
      _pageController.jumpToPage(result.pageNumber! - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();
    final surah = provider.getSurahForPage(_currentPage);
    final isDark = provider.isNightMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF202020) : const Color(0xFFFAF8F3),
      body: Stack(
        children: [
          // ── Page viewer ──────────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _totalPages,
            onPageChanged: (index) {
              setState(() => _currentPage = index + 1);
            },
            itemBuilder: (context, index) => MushafPage(
              pageNumber: index + 1,
              onTap: _toggleOverlay,
            ),
          ),
          // ── Bottom overlay (barre flottante) ─────────────────────────────
          AnimatedSlide(
            offset: _showOverlay ? Offset.zero : const Offset(0, 1.5),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: _showOverlay ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showOverlay,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Consumer<QuranProvider>(
                        builder: (context, p, _) {
                          final isBookmarked = p.isPageBookmarked(_currentPage);
                          final iconColor = isDark ? Colors.white70 : Colors.black54;
                          final surahName = surah?.nameArabic ?? '';

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Info Sourate + Page ────────────────
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Juz indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.goldColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Juz ${((_currentPage - 1) ~/ 20) + 1}',
                                        style: AppTheme.labelStyle.copyWith(
                                          color: AppTheme.goldColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    // Surah name
                                    if (surahName.isNotEmpty)
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            surahName,
                                            style: AppTheme.arabicText.copyWith(
                                              fontSize: 18,
                                              color: isDark ? AppTheme.goldColor : AppTheme.darkGreen,
                                              fontWeight: FontWeight.bold,
                                              height: 1.4,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    // Page counter
                                    Text(
                                      '$_currentPage / $_totalPages',
                                      style: AppTheme.labelStyle.copyWith(
                                        color: isDark ? Colors.white54 : Colors.black45,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // ── Slider de navigation ───────────────
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: AppTheme.goldColor,
                                  inactiveTrackColor: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                  thumbColor: AppTheme.goldColor,
                                  overlayColor: AppTheme.goldColor.withOpacity(0.15),
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                  trackHeight: 3,
                                ),
                                child: Slider(
                                  value: _currentPage.toDouble(),
                                  min: 1,
                                  max: _totalPages.toDouble(),
                                  onChanged: (value) {
                                    final page = value.round();
                                    setState(() => _currentPage = page);
                                    _pageController.jumpToPage(page - 1);
                                  },
                                ),
                              ),

                              const SizedBox(height: 2),

                              // ── Boutons de contrôle ────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Retour
                                  _OverlayButton(
                                    icon: Icons.arrow_back_ios_new_rounded,
                                    label: 'Retour',
                                    color: iconColor,
                                    onTap: () => Navigator.of(context).pop(),
                                  ),
                                  // Recherche
                                  _OverlayButton(
                                    icon: Icons.search_rounded,
                                    label: 'Chercher',
                                    color: iconColor,
                                    onTap: _openSearch,
                                  ),
                                  // Lecture audio (bouton principal)
                                  _OverlayButton(
                                    icon: p.isPlaying
                                        ? Icons.stop_circle_rounded
                                        : Icons.play_circle_fill_rounded,
                                    label: p.isPlaying ? 'Arrêter' : 'Écouter',
                                    color: p.isPlaying
                                        ? Colors.redAccent
                                        : AppTheme.goldColor,
                                    size: 32,
                                    onTap: p.isPlaying
                                        ? p.stopAudio
                                        : () => p.playPage(_currentPage),
                                  ),
                                  // Favoris
                                  _OverlayButton(
                                    icon: isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    label: 'Favoris',
                                    color: isBookmarked
                                        ? AppTheme.goldColor
                                        : iconColor,
                                    onTap: () =>
                                        p.toggleBookmark(_currentPage),
                                  ),
                                  // Mode nuit
                                  _OverlayButton(
                                    icon: p.isNightMode
                                        ? Icons.wb_sunny_rounded
                                        : Icons.nightlight_round,
                                    label: p.isNightMode ? 'Clair' : 'Sombre',
                                    color: iconColor,
                                    onTap: p.toggleNightMode,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Petit bouton icône + label pour l'overlay du Mushaf.
class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _OverlayButton({
    required this.icon,
    required this.label,
    required this.color,
    this.size = 24,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: size),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
