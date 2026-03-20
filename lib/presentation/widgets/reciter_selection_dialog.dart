import 'package:flutter/material.dart';
import '../../core/api/qul_service.dart';
import '../../core/cache/models/qul_recitation_model.dart';
import '../../core/theme/app_theme.dart';

class ReciterSelectionDialog extends StatefulWidget {
  final String currentReciterId;
  final Function(String, String) onReciterSelected;

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
      final reciters = _qulService.getReciters();
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
    final maxHeight = MediaQuery.of(context).size.height * 0.55;

    return AlertDialog(
      title: const Text('Select Reciter'),
      content: SizedBox(
        width: 300,
        height: _isLoading ? 120 : maxHeight,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _reciters.length,
                itemBuilder: (context, index) {
                  final reciter = _reciters[index];
                  final isSelected =
                      reciter.id == widget.currentReciterId;

                  return ListTile(
                    title: Text(reciter.name),
                    subtitle: Text(reciter.style),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppTheme.goldColor)
                        : null,
                    selected: isSelected,
                    selectedTileColor:
                        AppTheme.goldColor.withOpacity(0.06),
                    onTap: () {
                      widget.onReciterSelected(reciter.id, reciter.name);
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
}
