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
        title: const Text('Al-Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
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
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
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
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.secondaryColor,
                    child: Text(
                      '${surah.id}',
                      style: const TextStyle(color: AppTheme.primaryColor),
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
    );
  }
}
