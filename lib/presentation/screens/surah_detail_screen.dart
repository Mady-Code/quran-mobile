import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../features/quran/domain/entities/surah.dart';
import '../../features/quran/domain/entities/verse.dart';
import '../providers/quran_provider.dart';
import '../widgets/mushaf_page.dart';
import '../widgets/verse_search_delegate.dart';
import '../../core/theme/app_theme.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? startPage;

  const SurahDetailScreen({
    super.key, 
    required this.surah,
    this.startPage,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    // Enable fullscreen immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    final initialPage = widget.startPage ?? (widget.surah.pages.isNotEmpty ? widget.surah.pages[0] : 1);
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage - 1);
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  void _openSearch() async {
    final result = await showSearch<Verse?>(
      context: context,
      delegate: VerseSearchDelegate(),
    );

    if (result != null && result.pageNumber != null) {
      setState(() {
        _currentPage = result.pageNumber!;
      });
      _pageController.jumpToPage(result.pageNumber! - 1);
    }
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  void _nextPage() {
    if (_currentPage < 604) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final surah = context.read<QuranProvider>().getSurahForPage(_currentPage) ?? widget.surah;

    // We can use the provider's night mode setting to toggle theme locally if we supported full theme switching,
    // but here we just handle specific UI elements for the overlay.
    // The MushafPage itself handles the image inversion.

    return Scaffold(
      backgroundColor: AppTheme.creamColor, // Match app theme
      body: Stack(
        children: [
          // Main PageView - Full width
          PageView.builder(
            controller: _pageController,
            itemCount: 604,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index + 1;
              });
            },
            itemBuilder: (context, index) {
              final pageNumber = index + 1;
              return MushafPage(
                pageNumber: pageNumber,
                onTap: _toggleOverlay,
              );
            },
          ),
          
          // Top overlay - Surah name
          if (_showOverlay)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.creamColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      surah.nameArabic,
                      style: AppTheme.arabicText.copyWith(
                        fontSize: 24,
                        color: AppTheme.creamColor, 
                        // Using cream for text on dark overlay
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: AppTheme.creamColor),
                      onPressed: _openSearch,
                    ),
                  ],
                ),
              ),
            ),
          
          // Bottom overlay - Page number
          if (_showOverlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                  builder: (context, provider, child) {
                    final isBookmarked = provider.isPageBookmarked(_currentPage);
                    final isPlaying = provider.isPlaying;
                    // final isNightMode = provider.isNightMode;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Bookmark Button (Direct)
                            IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: isBookmarked ? AppTheme.goldColor : AppTheme.creamColor,
                              ),
                              onPressed: () => provider.toggleBookmark(_currentPage),
                            ),
                             // Audio Menu Button (Separate)
                             IconButton(
                              icon: const Icon(Icons.headphones, color: AppTheme.creamColor),
                              onPressed: () => _showAudioMenu(context, provider),
                            ),
                            // Settings Menu Button (Theme inside)
                            IconButton(
                              icon: const Icon(Icons.settings, color: AppTheme.creamColor),
                              onPressed: () => _showSettingsMenu(context, provider),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Page $_currentPage',
                          style: AppTheme.subtitleStyle.copyWith(color: AppTheme.creamColor.withOpacity(0.8)),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context, QuranProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: provider.isNightMode ? const Color(0xFF303030) : AppTheme.creamColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Paramètres', style: AppTheme.titleStyle.copyWith(
                  color: provider.isNightMode ? Colors.white : AppTheme.blackText
                )),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  provider.isNightMode ? Icons.wb_sunny : Icons.nightlight_round,
                  color: AppTheme.goldColor
                ),
                title: Text('Mode Nuit', style: AppTheme.bodyStyle.copyWith(
                  color: provider.isNightMode ? Colors.white : AppTheme.blackText
                )),
                trailing: Switch(
                  activeColor: AppTheme.goldColor,
                  value: provider.isNightMode,
                  onChanged: (_) {
                    provider.toggleNightMode();
                    Navigator.pop(context); 
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAudioMenu(BuildContext context, QuranProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isPlaying = provider.isPlaying;
        return Container(
          decoration: BoxDecoration(
            color: provider.isNightMode ? const Color(0xFF303030) : AppTheme.creamColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Lecture Audio', style: AppTheme.titleStyle.copyWith(
                   color: provider.isNightMode ? Colors.white : AppTheme.blackText
                )),
              ),
              const Divider(),
              ListTile(
                leading: Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 32, color: AppTheme.goldColor),
                title: Text(
                  isPlaying ? 'Arrêter la lecture' : 'Lire la page $_currentPage',
                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, color: provider.isNightMode ? Colors.white : AppTheme.blackText)
                ),
                subtitle: const Text('Récitateur : Mishary Rashid Alafasy'),
                onTap: () {
                   if (isPlaying) {
                      provider.stopAudio();
                   } else {
                      provider.playPage(_currentPage);
                   }
                   Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
