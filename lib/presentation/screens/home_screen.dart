import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';import '../widgets/surah_card.dart';
import '../widgets/verse_search_delegate.dart';
import '../../features/quran/domain/entities/surah.dart';
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
    // Fetch surahs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().fetchSurahs();
      context.read<QuranProvider>().loadBookmarks();
      context.read<QuranProvider>().loadInteractionData();
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
            onPressed: () {
               showSearch(
                context: context,
                delegate: VerseSearchDelegate(),
              );
            },
            color: AppTheme.blackText,
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
                  Text('Error: ${provider.error}', style: AppTheme.bodyStyle),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => provider.fetchSurahs(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: provider.surahs.length,
            itemBuilder: (context, index) {
              final surah = provider.surahs[index];
              return SurahCard(
                surah: surah,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurahDetailScreen(surah: surah),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
        child: Container(
          color: AppTheme.creamColor,
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppTheme.goldColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Icon(Icons.menu_book, size: 48, color: Colors.white),
                       const SizedBox(height: 10),
                       Text(
                        'Menu',
                        style: AppTheme.headingStyle.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark, color: AppTheme.goldColor),
                title: Text('Signets (Bookmarks)', style: AppTheme.titleStyle),
              ),
              Expanded(
                child: Consumer<QuranProvider>(
                  builder: (context, provider, child) {
                    final bookmarks = provider.bookmarks;
                    if (bookmarks.isEmpty) {
                      return Center(child: Text('Aucun signet', style: AppTheme.subtitleStyle));
                    }
                    return ListView.builder(
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        final pageNum = bookmarks[index];
                        return ListTile(
                          title: Text('Page $pageNum', style: AppTheme.bodyStyle),
                          subtitle: Text(provider.getSurahForPage(pageNum)?.nameSimple ?? 'Inconnu'),
                          onTap: () {
                            Navigator.pop(context); // Close drawer
                            final surah = provider.getSurahForPage(pageNum);
                            if (surah != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SurahDetailScreen(
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
        ),
      );
  }
}
