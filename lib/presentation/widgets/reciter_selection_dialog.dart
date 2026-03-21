import 'package:flutter/material.dart';
import '../../core/api/qul_service.dart';
import '../../core/cache/models/qul_recitation_model.dart';
import '../../core/theme/app_theme.dart';

class ReciterSelectionDialog extends StatefulWidget {
  final String currentReciterId;
  final Function(String, String, String?) onReciterSelected;

  const ReciterSelectionDialog({
    super.key,
    required this.currentReciterId,
    required this.onReciterSelected,
  });

  @override
  State<ReciterSelectionDialog> createState() => _ReciterSelectionDialogState();
}

class _ReciterSelectionDialogState extends State<ReciterSelectionDialog> {
  final QulService _qulService = QulService();
  List<QulReciter> _reciters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReciters();
  }

  Future<void> _loadReciters() async {
    try {
      final reciters = await _qulService.getReciters();
      if (mounted) {
        setState(() {
          _reciters = reciters;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppTheme.darkSurface : Colors.white;
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────────────
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

          // ── Header ────────────────────────────────────────────────────
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
                  child: const Icon(Icons.mic_rounded,
                      color: AppTheme.goldColor, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Reciter', style: AppTheme.titleStyle),
                    Text(
                      '${_reciters.length} reciters available',
                      style: AppTheme.subtitleStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Content ───────────────────────────────────────────────────
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(color: AppTheme.goldColor),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _reciters.length,
                itemBuilder: (context, index) {
                  final reciter = _reciters[index];
                  final isSelected = reciter.id == widget.currentReciterId;

                  return InkWell(
                    onTap: () {
                      widget.onReciterSelected(
                          reciter.id, reciter.name, reciter.audioAssets);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                              Icons.person_rounded,
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
                                  reciter.name,
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
                                  reciter.style,
                                  style: AppTheme.subtitleStyle.copyWith(
                                    color: isDark
                                        ? AppTheme.darkSubtitle
                                        : AppTheme.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Check
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.goldColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // ── Cancel button ─────────────────────────────────────────────
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
}
