import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';
import '../widgets/surah_card.dart';
import '../widgets/verse_search_delegate.dart';
import 'surah_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<QuranProvider>();
      provider.fetchSurahs();
      provider.loadBookmarks();
      provider.loadInteractionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Al-Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search verses',
            onPressed: () {
              showSearch(
                context: context,
                delegate: VerseSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 12),
                  Text('Failed to load surahs',
                      style: AppTheme.headingStyle
                          .copyWith(color: AppTheme.greyText)),
                  const SizedBox(height: 6),
                  Text(provider.error!,
                      style: AppTheme.subtitleStyle,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () => provider.fetchSurahs(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.goldColor,
            onRefresh: () => provider.fetchSurahs(),
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              itemCount: provider.surahs.length,
              itemBuilder: (context, index) {
                final surah = provider.surahs[index];
                return SurahCard(
                  surah: surah,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahDetailScreen(surah: surah),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.goldColor),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 44, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    'Al-Quran',
                    style: AppTheme.headingStyle.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'My Bookmarks',
                    style: AppTheme.subtitleStyle
                        .copyWith(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          // ── Bookmarks list ────────────────────────────────────────────────
          Expanded(
            child: Consumer<QuranProvider>(
              builder: (context, provider, child) {
                final bookmarks = provider.bookmarks;
                if (bookmarks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border,
                            size: 48,
                            color: AppTheme.greyText.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text('No bookmarks yet',
                            style: AppTheme.subtitleStyle),
                        const SizedBox(height: 6),
                        Text('Long-press a page in Mushaf view\nto bookmark it',
                            style: AppTheme.subtitleStyle
                                .copyWith(fontSize: 12),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final pageNum = bookmarks[index];
                    final surah = provider.getSurahForPage(pageNum);
                    return ListTile(
                      leading: const Icon(Icons.bookmark,
                          color: AppTheme.goldColor, size: 20),
                      title: Text('Page $pageNum',
                          style: AppTheme.bodyStyle),
                      subtitle: Text(
                          surah?.nameSimple ?? 'Unknown surah',
                          style: AppTheme.subtitleStyle),
                      onTap: () {
                        Navigator.pop(context);
                        if (surah != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurahDetailScreen(
                                surah: surah,
                                startPage: pageNum,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
