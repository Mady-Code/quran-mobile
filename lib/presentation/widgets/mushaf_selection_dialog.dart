import 'package:flutter/material.dart';
import '../../features/quran/domain/entities/mushaf_type.dart';
import '../../core/theme/app_theme.dart';

class MushafSelectionDialog extends StatelessWidget {
  final MushafType currentType;
  final Function(MushafType) onTypeSelected;

  const MushafSelectionDialog({
    super.key,
    required this.currentType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppTheme.darkSurface : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white24
                    : Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: AppTheme.goldColor, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Qiraat Style', style: AppTheme.titleStyle),
                    Text(
                      'Choose your preferred recitation style',
                      style: AppTheme.subtitleStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Options ──────────────────────────────────────────────────
          ...MushafType.values.map((type) {
            final isSelected = type == currentType;
            final label = _getMushafLabel(type);
            final description = _getMushafDescription(type);

            return InkWell(
              onTap: () {
                onTypeSelected(type);
                Navigator.pop(context);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? AppTheme.goldColor.withOpacity(0.15)
                            : (isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.grey.shade100),
                        border: isSelected
                            ? Border.all(
                                color: AppTheme.goldColor, width: 1.5)
                            : null,
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: isSelected
                            ? AppTheme.goldColor
                            : AppTheme.greyText,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTheme.bodyStyle.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.goldColor
                                  : (isDark
                                      ? AppTheme.darkText
                                      : AppTheme.blackText),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: AppTheme.subtitleStyle.copyWith(
                              color: isDark
                                  ? AppTheme.darkSubtitle
                                  : AppTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Check indicator
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.goldColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14),
                      )
                    else
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.white24
                                : Colors.black.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),

          // ── Cancel ───────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTheme.bodyStyle.copyWith(
                      color: isDark ? AppTheme.darkText : AppTheme.blackText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  String _getMushafDescription(MushafType type) {
    switch (type) {
      case MushafType.hafs:
        return 'Most widely used · Narrated from Asim';
      case MushafType.warsh:
        return 'Used in North & West Africa';
      case MushafType.shubah:
        return 'Narrated from Asim via Shu\'bah';
      case MushafType.qalon:
        return 'Used in Libya and Tunisia';
      case MushafType.douri:
        return 'Narrated from Abu Amr via Ad-Douri';
    }
  }
}
