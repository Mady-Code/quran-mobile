import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/surah.dart';
import '../../data/models/verse.dart';
import '../providers/quran_provider.dart';
import '../widgets/mushaf_page.dart';
import '../widgets/verse_search_delegate.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
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
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      surah.nameArabic,
                      style: const TextStyle(
                        fontFamily: 'KFGQPC Uthmanic Script HAFS',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
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
                    final isNightMode = provider.isNightMode;

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
                                color: isBookmarked ? Colors.amber : Colors.white,
                              ),
                              onPressed: () => provider.toggleBookmark(_currentPage),
                            ),
                             // Audio Menu Button (Separate)
                             IconButton(
                              icon: const Icon(Icons.headphones, color: Colors.white),
                              onPressed: () => _showAudioMenu(context, provider),
                            ),
                            // Settings Menu Button (Theme inside)
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white),
                              onPressed: () => _showSettingsMenu(context, provider),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Page $_currentPage',
                          style: const TextStyle(
                            fontFamily: 'KFGQPC Uthmanic Script HAFS',
                            fontSize: 14,
                            color: Colors.white70,
                          ),
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
            color: provider.isNightMode ? const Color(0xFF303030) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Paramètres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              ListTile(
                leading: Icon(provider.isNightMode ? Icons.wb_sunny : Icons.nightlight_round),
                title: const Text('Mode Nuit'),
                trailing: Switch(
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
            color: provider.isNightMode ? const Color(0xFF303030) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Lecture Audio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              ListTile(
                leading: Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 32, color: Colors.amber),
                title: Text(isPlaying ? 'Arrêter la lecture' : 'Lire la page $_currentPage'),
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
