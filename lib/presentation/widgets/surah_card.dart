import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark
        ? AppTheme.goldColor.withOpacity(0.12)
        : AppTheme.goldColor.withOpacity(0.2);
    final subtitleColor = isDark ? AppTheme.darkSubtitle : AppTheme.greyText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.goldColor.withOpacity(0.08),
          highlightColor: AppTheme.goldColor.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                // ── Number badge ──────────────────────────────────────────
                _NumberBadge(number: surah.id, isDark: isDark),
                const SizedBox(width: 14),

                // ── Surah info ────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.nameSimple,
                        style: AppTheme.titleStyle.copyWith(
                          color: isDark ? AppTheme.darkText : AppTheme.blackText,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _RevelationBadge(place: surah.revelationPlace),
                          const SizedBox(width: 8),
                          Text(
                            '${surah.versesCount} verses',
                            style: AppTheme.subtitleStyle.copyWith(
                                color: subtitleColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Arabic name ───────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      surah.nameArabic,
                      style: const TextStyle(
                        fontFamily: 'KFGQPC Uthmanic Script HAFS',
                        fontSize: 20,
                        color: AppTheme.goldColor,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  final bool isDark;

  const _NumberBadge({required this.number, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Diamond shape
        Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.goldColor, width: 1.5),
              color: isDark
                  ? AppTheme.goldColor.withOpacity(0.08)
                  : AppTheme.goldColor.withOpacity(0.06),
            ),
          ),
        ),
        Text(
          '$number',
          style: GoogleFonts.poppins(
            fontSize: number > 99 ? 10 : 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.goldColor,
          ),
        ),
      ],
    );
  }
}

class _RevelationBadge extends StatelessWidget {
  final String place;

  const _RevelationBadge({required this.place});

  @override
  Widget build(BuildContext context) {
    final isMecca = place.toLowerCase() == 'mecca';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isMecca
            ? AppTheme.goldColor.withOpacity(0.12)
            : AppTheme.darkGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        place,
        style: AppTheme.labelStyle.copyWith(
          fontSize: 10,
          color: isMecca ? AppTheme.goldColor : AppTheme.darkGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
