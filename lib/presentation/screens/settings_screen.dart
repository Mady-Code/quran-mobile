import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/reciter_selection_dialog.dart';
import '../widgets/mushaf_selection_dialog.dart';
import '../../features/quran/domain/entities/mushaf_type.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/injection_container.dart';
import '../../core/cache/cache_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, int> _cacheStats = {'surahs': 0, 'recitations': 0};

  @override
  void initState() {
    super.initState();
    _refreshCacheStats();
  }

  void _refreshCacheStats() {
    final stats = sl<CacheService>().getStats();
    if (mounted) setState(() => _cacheStats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader('Audio'),
          _buildReciterTile(context),

          const Divider(height: 32),

          _buildSectionHeader('Cache'),
          _buildCacheStatsTile(context),
          _buildClearCacheTile(context),

          const Divider(height: 32),

          _buildSectionHeader('Display'),
          _buildMushafTile(context),
          _buildNightModeTile(context),

          const Divider(height: 32),

          _buildSectionHeader('About'),
          _buildAboutTile(context),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.goldColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkGreen,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Reciter ────────────────────────────────────────────────────────────────
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
              builder: (_) => ReciterSelectionDialog(
                currentReciterId: settings.reciterId,
                onReciterSelected: (id, name) {
                  settings.setReciter(id, name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reciter changed to $name'),
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

  // ── Cache stats ────────────────────────────────────────────────────────────
  Widget _buildCacheStatsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.storage, color: AppTheme.goldColor),
      title: const Text('Cache Statistics'),
      subtitle: Text(
          'Surahs: ${_cacheStats['surahs']}, Recitations: ${_cacheStats['recitations']}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCacheStatsDialog(context, _cacheStats),
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
          await sl<CacheService>().clearAll();
          _refreshCacheStats();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cache cleared successfully')),
            );
          }
        }
      },
    );
  }

  // ── Display ────────────────────────────────────────────────────────────────
  Widget _buildMushafTile(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return ListTile(
          leading: const Icon(Icons.menu_book, color: AppTheme.goldColor),
          title: const Text('Qiraat Style'),
          subtitle: Text(_getMushafLabel(settings.mushafType)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => MushafSelectionDialog(
                currentType: settings.mushafType,
                onTypeSelected: (type) {
                  settings.setMushafType(type);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Qiraat style changed to ${_getMushafLabel(type)}'),
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

  String _getMushafLabel(MushafType type) {
    switch (type) {
      case MushafType.hafs:
        return 'Hafs (Medina)';
      case MushafType.warsh:
        return 'Warsh';
      case MushafType.shubah:
        return "Shu'bah";
      case MushafType.qalon:
        return 'Qalon';
      case MushafType.douri:
        return 'Ad-Douri';
    }
  }

  Widget _buildNightModeTile(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return SwitchListTile(
          secondary: const Icon(Icons.dark_mode, color: AppTheme.goldColor),
          title: const Text('Night Mode'),
          subtitle: const Text('Dark theme for comfortable reading'),
          value: settings.nightMode,
          onChanged: (_) {
            settings.toggleNightMode();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(settings.nightMode
                    ? 'Night mode disabled'
                    : 'Night mode enabled'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  // ── About ──────────────────────────────────────────────────────────────────
  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: AppTheme.goldColor),
      title: const Text('About'),
      subtitle: const Text('Version 1.0.0'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'Al-Quran',
          applicationVersion: '1.0.0',
          applicationIcon:
              const Icon(Icons.book, size: 48, color: AppTheme.goldColor),
          children: const [
            Text('A beautiful Quran app with offline-first architecture.'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• 114 Surahs with Uthmanic script'),
            Text('• Multiple reciters'),
            Text('• Offline caching'),
            Text('• Night mode'),
          ],
        );
      },
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────
  void _showCacheStatsDialog(BuildContext context, Map<String, int> stats) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
              'Cached data loads significantly faster than fetching from the network.',
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
      BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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
