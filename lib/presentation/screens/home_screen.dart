import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';
import '../widgets/surah_card.dart';
import '../widgets/verse_search_delegate.dart';
import 'mushaf_screen.dart';

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
      body: RefreshIndicator(
        color: AppTheme.goldColor,
        onRefresh: () => context.read<QuranProvider>().fetchSurahs(),
        child: Consumer<QuranProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),

                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.goldColor),
                    ),
                  )
                else if (provider.error != null)
                  SliverFillRemaining(
                    child: _buildErrorState(context, provider),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final surah = provider.surahs[index];
                          return SurahCard(
                            surah: surah,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MushafScreen(startPage: surah.pages.isNotEmpty ? surah.pages[0] : 1),
                              ),
                            ),
                          );
                        },
                        childCount: provider.surahs.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white),
          tooltip: 'Search verses',
          onPressed: () => showSearch(
            context: context,
            delegate: VerseSearchDelegate(),
          ),
        ),
      ],
      backgroundColor: AppTheme.darkGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroBanner(),
        collapseMode: CollapseMode.parallax,
      ),
      title: Text(
        'Al-Quran',
        style: AppTheme.titleStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkGreen,
            Color(0xFF2A6B42),
            Color(0xFF3D8A57),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldColor.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 60,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldColor.withOpacity(0.06),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(
                      fontFamily: 'KFGQPC Uthmanic Script HAFS',
                      fontSize: 22,
                      color: Colors.white,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'THE HOLY QURAN',
                    style: AppTheme.labelStyle.copyWith(
                      color: AppTheme.goldLight,
                      fontSize: 11,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, QuranProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
          ),
          const SizedBox(height: 20),
          Text('Failed to load surahs',
              style: AppTheme.headingStyle.copyWith(
                fontSize: 18,
                color: isDark ? AppTheme.darkText : AppTheme.blackText,
              )),
          const SizedBox(height: 8),
          Text(provider.error!,
              style: AppTheme.subtitleStyle,
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            onPressed: () => provider.fetchSurahs(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.darkGreen, Color(0xFF3D8A57)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      size: 28, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Al-Quran',
                  style: AppTheme.headingStyle.copyWith(
                      color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'My Bookmarks',
                  style: AppTheme.subtitleStyle.copyWith(
                      color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Bookmarks list ────────────────────────────────────────────
          Expanded(
            child: Consumer<QuranProvider>(
              builder: (context, provider, child) {
                final bookmarks = provider.bookmarks;
                if (bookmarks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border_rounded,
                            size: 52,
                            color: AppTheme.greyText.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text('No bookmarks yet',
                            style: AppTheme.titleStyle.copyWith(
                                color: AppTheme.greyText, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          'Long-press a page in Mushaf\nview to bookmark it',
                          style: AppTheme.subtitleStyle
                              .copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final pageNum = bookmarks[index];
                    final surah = provider.getSurahForPage(pageNum);
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.goldColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bookmark_rounded,
                            color: AppTheme.goldColor, size: 18),
                      ),
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
                              builder: (_) => MushafScreen(
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
