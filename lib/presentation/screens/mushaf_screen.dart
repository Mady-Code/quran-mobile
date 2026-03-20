import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';
import '../widgets/mushaf_page.dart';
import '../widgets/verse_search_delegate.dart';
import '../../features/quran/domain/entities/verse.dart';

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _showOverlay = false;

  static const int _totalPages = 604;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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

          // ── Top overlay ──────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showOverlay ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showOverlay,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 44, 8, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close full-screen overlay hint
                      IconButton(
                        icon:
                            const Icon(Icons.close, color: AppTheme.creamColor),
                        tooltip: 'Hide controls',
                        onPressed: _toggleOverlay,
                      ),
                      if (surah != null)
                        Text(
                          surah.nameArabic,
                          style: AppTheme.arabicText.copyWith(
                            fontSize: 22,
                            color: AppTheme.creamColor,
                            height: 1.2,
                          ),
                        ),
                      IconButton(
                        icon:
                            const Icon(Icons.search, color: AppTheme.creamColor),
                        tooltip: 'Search verses',
                        onPressed: _openSearch,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom overlay ───────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showOverlay ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showOverlay,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Consumer<QuranProvider>(
                    builder: (context, p, _) {
                      final isBookmarked = p.isPageBookmarked(_currentPage);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Bookmark
                              Tooltip(
                                message: isBookmarked
                                    ? 'Remove bookmark'
                                    : 'Bookmark page',
                                child: IconButton(
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isBookmarked
                                        ? AppTheme.goldColor
                                        : AppTheme.creamColor,
                                  ),
                                  onPressed: () =>
                                      p.toggleBookmark(_currentPage),
                                ),
                              ),
                              // Audio
                              Tooltip(
                                message: p.isPlaying
                                    ? 'Stop audio'
                                    : 'Play this page',
                                child: IconButton(
                                  icon: Icon(
                                    p.isPlaying
                                        ? Icons.stop_circle_outlined
                                        : Icons.headphones,
                                    color: AppTheme.creamColor,
                                  ),
                                  onPressed: p.isPlaying
                                      ? p.stopAudio
                                      : () => p.playPage(_currentPage),
                                ),
                              ),
                              // Night mode
                              Tooltip(
                                message: p.isNightMode
                                    ? 'Light mode'
                                    : 'Night mode',
                                child: IconButton(
                                  icon: Icon(
                                    p.isNightMode
                                        ? Icons.wb_sunny
                                        : Icons.nightlight_round,
                                    color: AppTheme.creamColor,
                                  ),
                                  onPressed: p.toggleNightMode,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Page $_currentPage / $_totalPages',
                            style: AppTheme.subtitleStyle.copyWith(
                                color: AppTheme.creamColor.withOpacity(0.8)),
                          ),
                        ],
                      );
                    },
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
