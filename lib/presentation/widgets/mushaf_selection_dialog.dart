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
    return AlertDialog(
      title: const Text('Select Qiraat Style'),
      content: SizedBox(
        width: 300,
        height: MediaQuery.of(context).size.height * 0.4,
        child: ListView.builder(
          itemCount: MushafType.values.length,
          itemBuilder: (context, index) {
            final type = MushafType.values[index];
            final isSelected = type == currentType;

            return ListTile(
              title: Text(
                _getMushafLabel(type),
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.darkGreen : null,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
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
}
