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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.creamColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            title: const Text('Settings'),
            backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Audio section ─────────────────────────────────────────
                _SectionCard(
                  icon: Icons.headphones_rounded,
                  title: 'Audio',
                  isDark: isDark,
                  children: [
                    _buildReciterTile(context),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Display section ───────────────────────────────────────
                _SectionCard(
                  icon: Icons.palette_outlined,
                  title: 'Display',
                  isDark: isDark,
                  children: [
                    _buildMushafTile(context),
                    const _TileDivider(),
                    _buildNightModeTile(context),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Cache section ─────────────────────────────────────────
                _SectionCard(
                  icon: Icons.storage_rounded,
                  title: 'Cache',
                  isDark: isDark,
                  children: [
                    _buildCacheStatsTile(context),
                    const _TileDivider(),
                    _buildClearCacheTile(context),
                  ],
                ),
                const SizedBox(height: 14),

                // ── About section ─────────────────────────────────────────
                _SectionCard(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  isDark: isDark,
                  children: [
                    _buildAboutTile(context),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reciter ──────────────────────────────────────────────────────────────
  Widget _buildReciterTile(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return _SettingsTile(
          icon: Icons.person_rounded,
          title: 'Reciter',
          subtitle: settings.reciterName,
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppTheme.greyText),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ReciterSelectionDialog(
                currentReciterId: settings.reciterId,
                onReciterSelected: (id, name, audioAssets) {
                  settings.setReciter(id, name, audioAssets);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reciter changed to $name')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ── Cache stats ──────────────────────────────────────────────────────────
  Widget _buildCacheStatsTile(BuildContext context) {
    return _SettingsTile(
      icon: Icons.bar_chart_rounded,
      title: 'Cache Statistics',
      subtitle:
          'Surahs: ${_cacheStats['surahs']}  ·  Recitations: ${_cacheStats['recitations']}',
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.greyText),
      onTap: () => _showCacheStatsDialog(context, _cacheStats),
    );
  }

  Widget _buildClearCacheTile(BuildContext context) {
    return _SettingsTile(
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red.shade400,
      title: 'Clear Cache',
      subtitle: 'Free up storage space',
      onTap: () async {
        final confirm = await _showConfirmDialog(
          context,
          'Clear Cache?',
          'This will delete all cached data. The app will re-download when needed.',
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

  // ── Display ──────────────────────────────────────────────────────────────
  Widget _buildMushafTile(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return _SettingsTile(
          icon: Icons.menu_book_rounded,
          title: 'Qiraat Style',
          subtitle: _getMushafLabel(settings.mushafType),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppTheme.greyText),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => MushafSelectionDialog(
                currentType: settings.mushafType,
                onTypeSelected: (type) {
                  settings.setMushafType(type);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Qiraat style changed to ${_getMushafLabel(type)}'),
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
        return _SettingsTile(
          icon: settings.nightMode
              ? Icons.wb_sunny_rounded
              : Icons.nightlight_round_rounded,
          title: 'Night Mode',
          subtitle: 'Dark theme for comfortable reading',
          trailing: Switch(
            value: settings.nightMode,
            activeColor: AppTheme.goldColor,
            onChanged: (_) {
              settings.toggleNightMode();
            },
          ),
          onTap: () => settings.toggleNightMode(),
        );
      },
    );
  }

  // ── About ────────────────────────────────────────────────────────────────
  Widget _buildAboutTile(BuildContext context) {
    return _SettingsTile(
      icon: Icons.info_outline_rounded,
      title: 'About Al-Quran',
      subtitle: 'Version 1.0.0',
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.greyText),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'Al-Quran',
          applicationVersion: '1.0.0',
          applicationIcon:
              const Icon(Icons.book_rounded, size: 48, color: AppTheme.goldColor),
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

  // ── Dialogs ──────────────────────────────────────────────────────────────
  void _showCacheStatsDialog(BuildContext context, Map<String, int> stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cache Statistics', style: AppTheme.titleStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow(context, 'Surahs cached', '${stats['surahs']}'),
            const SizedBox(height: 10),
            _buildStatRow(
                context, 'Recitations cached', '${stats['recitations']}'),
            const SizedBox(height: 16),
            Text(
              'Cached data loads significantly faster than fetching from the network.',
              style: AppTheme.subtitleStyle.copyWith(fontSize: 12),
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

  Widget _buildStatRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTheme.bodyStyle.copyWith(
                color: isDark ? AppTheme.darkText : AppTheme.blackText)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.goldColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: AppTheme.titleStyle.copyWith(
                color: AppTheme.goldColor, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<bool?> _showConfirmDialog(
      BuildContext context, String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTheme.titleStyle),
        content: Text(message, style: AppTheme.bodyStyle),
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

// ── Section card ───────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: AppTheme.goldColor),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTheme.labelStyle.copyWith(
                  color: AppTheme.goldColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        // Card container
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppTheme.goldColor.withOpacity(0.1)
                  : AppTheme.goldColor.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ── Settings tile ──────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? AppTheme.goldColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkText : AppTheme.blackText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.subtitleStyle.copyWith(
                      color: isDark ? AppTheme.darkSubtitle : AppTheme.greyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ── Tile divider ───────────────────────────────────────────────────────────
class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.06),
      ),
    );
  }
}
