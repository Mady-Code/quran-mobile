import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
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
    return AlertDialog(
      title: const Text('Sélectionner le Style de Mushaf'),
      backgroundColor: AppTheme.creamColor,
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: MushafType.values.length,
          itemBuilder: (context, index) {
            final type = MushafType.values[index];
            final isSelected = type == currentType;

            return ListTile(
              title: Text(
                _getMushafLabel(type),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.darkGreen : Colors.black87,
                ),
              ),
              trailing: isSelected 
                  ? const Icon(Icons.check_circle, color: AppTheme.darkGreen)
                  : null,
              onTap: () {
                onTypeSelected(type);
                Navigator.pop(context);
              },
            );
          },
        ),
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
        return 'Shub\'ah';
      case MushafType.qalon:
        return 'Qalon';
      case MushafType.douri:
        return 'Ad-Douri';
    }
  }
}
