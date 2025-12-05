import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/quran_provider.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8), // Beige/cream background
        elevation: 0,
        title: const Text(
          'Al-Quran',
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F1E8), // Beige/cream background like Mushaf pages
        child: Consumer<QuranProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37), // Gold color
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}'),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                      ),
                      onPressed: () => provider.fetchSurahs(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.surahs.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final surah = provider.surahs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF5), // Lighter inner background
                    border: Border.all(
                      color: const Color(0xFFD4AF37), // Gold border
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${surah.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      surah.nameSimple,
                      style: AppTheme.headingStyle.copyWith(fontSize: 18),
                    ),
                    subtitle: Text(
                      '${surah.revelationPlace} • ${surah.versesCount} Verses',
                      style: AppTheme.subtitleStyle,
                    ),
                    trailing: Text(
                      surah.nameArabic,
                      style: AppTheme.arabicText.copyWith(fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen(surah: surah),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
