import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/reciter_selection_dialog.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/injection_container.dart';
import '../../core/cache/cache_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.creamColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Audio Section
          _buildSectionHeader('AUDIO'),
          _buildReciterTile(context),
          
          const Divider(height: 32),
          
          // Cache Section
          _buildSectionHeader('CACHE'),
          _buildCacheStatsTile(context),
          _buildClearCacheTile(context),
          
          const Divider(height: 32),
          
          // Display Section
          _buildSectionHeader('DISPLAY'),
          _buildNightModeTile(context),
          
          const Divider(height: 32),
          
          // About Section
          _buildSectionHeader('ABOUT'),
          _buildAboutTile(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.darkGreen,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildReciterTile(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return ListTile(
          leading: const Icon(Icons.person, color: AppTheme.goldColor),
          title: const Text('Reciter'),
          subtitle: Text(settings.reciterName),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ReciterSelectionDialog(
                currentReciterEdition: settings.reciterEdition,
                onReciterSelected: (edition, name) {
                  settings.setReciter(edition, name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Reciter changed to $name'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCacheStatsTile(BuildContext context) {
    final cacheService = sl<CacheService>();
    final stats = cacheService.getStats();
    
    return ListTile(
      leading: const Icon(Icons.storage, color: AppTheme.goldColor),
      title: const Text('Cache Statistics'),
      subtitle: Text('Surahs: ${stats['surahs']}, Recitations: ${stats['recitations']}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showCacheStatsDialog(context, stats);
      },
    );
  }

  Widget _buildClearCacheTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_outline, color: Colors.red),
      title: const Text('Clear Cache'),
      subtitle: const Text('Free up storage space'),
      onTap: () async {
        final confirm = await _showConfirmDialog(
          context,
          'Clear Cache?',
          'This will delete all cached data. The app will re-download data when needed.',
        );
        
        if (confirm == true) {
          final cacheService = sl<CacheService>();
          await cacheService.clearAll();
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Cache cleared successfully')),
            );
          }
        }
      },
    );
  }

  Widget _buildNightModeTile(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return SwitchListTile(
          secondary: const Icon(Icons.dark_mode, color: AppTheme.goldColor),
          title: const Text('Night Mode'),
          subtitle: const Text('Dark theme for comfortable reading'),
          value: settings.nightMode,
          activeColor: AppTheme.goldColor,
          onChanged: (value) {
            settings.toggleNightMode();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value 
                    ? '🌙 Night mode enabled' 
                    : '☀️ Night mode disabled'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: AppTheme.goldColor),
      title: const Text('About'),
      subtitle: const Text('Version 1.0.0'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'Quran App',
          applicationVersion: '1.0.0',
          applicationIcon: const Icon(Icons.book, size: 48, color: AppTheme.goldColor),
          children: [
            const Text('A beautiful Quran app with offline-first architecture.'),
            const SizedBox(height: 16),
            const Text('Features:'),
            const Text('• 114 Surahs with Uthmanic script'),
            const Text('• Multiple reciters'),
            const Text('• Offline caching'),
            const Text('• Premium UI/UX'),
          ],
        );
      },
    );
  }

  void _showCacheStatsDialog(BuildContext context, Map<String, int> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Surahs cached', '${stats['surahs']}'),
            const SizedBox(height: 8),
            _buildStatRow('Recitations cached', '${stats['recitations']}'),
            const SizedBox(height: 16),
            const Text(
              'Cached data loads 10-15x faster than loading from JSON or API.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.goldColor,
          ),
        ),
      ],
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
