import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../../data/models/verse.dart';

class VerseSearchDelegate extends SearchDelegate<Verse?> {
  @override
  String get searchFieldLabel => 'Search verses...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text(
          'Enter text to search in Quran',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.length < 2) {
      return const Center(
        child: Text(
          'Please enter at least 2 characters',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final provider = context.read<QuranProvider>();
    
    return FutureBuilder<List<Verse>>(
      future: _searchVerses(provider, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return const Center(
            child: Text(
              'No verses found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final verse = results[index];
            final surah = provider.surahs.firstWhere(
              (s) => s.id == int.parse(verse.verseKey.split(':')[0]),
            );

            return ListTile(
              title: Text(
                verse.textUthmani,
                style: const TextStyle(
                  fontFamily: 'KFGQPC Uthmanic Script HAFS',
                  fontSize: 18,
                ),
                textDirection: TextDirection.rtl,
              ),
              subtitle: Text(
                '${surah.nameSimple} ${verse.verseKey} - Page ${verse.pageNumber}',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                close(context, verse);
              },
            );
          },
        );
      },
    );
  }

  Future<List<Verse>> _searchVerses(QuranProvider provider, String searchQuery) async {
    final allVerses = <Verse>[];
    
    // Load all verses from all surahs
    for (final surah in provider.surahs) {
      try {
        final verses = await provider.getVersesForSurah(surah.id);
        allVerses.addAll(verses);
      } catch (e) {
        // Skip if error loading surah
        continue;
      }
    }

    // Filter verses that contain the search query
    final lowerQuery = searchQuery.toLowerCase();
    return allVerses.where((verse) {
      return verse.textUthmani.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
