import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/quran/domain/entities/surah.dart';

class SurahCard extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const SurahCard({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              // Number Badge with Gold Border
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.goldColor, width: 1.5),
                  color: AppTheme.creamColor,
                ),
                child: Center(
                  child: Text(
                    '${surah.id}',
                    style: AppTheme.titleStyle.copyWith(
                      color: AppTheme.goldColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Surah Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameSimple,
                      style: AppTheme.titleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${surah.revelationPlace} • ${surah.versesCount} verses',
                      style: AppTheme.subtitleStyle,
                    ),
                  ],
                ),
              ),
              
              // Arabic Name
              Text(
                surah.nameArabic,
                style: AppTheme.arabicText.copyWith(
                  fontSize: 22,
                  color: AppTheme.goldColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
