import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart';
import '../../core/api/qul_service.dart';
import '../../core/cache/models/qul_recitation_model.dart';
import '../../core/theme/app_theme.dart';

class ReciterSelectionDialog extends StatefulWidget {
  final String currentReciterId;
  final Function(String, String) onReciterSelected;

  const ReciterSelectionDialog({
    Key? key,
    required this.currentReciterId,
    required this.onReciterSelected,
  }) : super(key: key);

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
      setState(() {
        // Get reciters from QulService
        _reciters = _qulService.getReciters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Reciter'),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _reciters.length,
                itemBuilder: (context, index) {
                  final reciter = _reciters[index];
                  final isSelected = reciter.id == widget.currentReciterId;
                  
                  return ListTile(
                    title: Text(reciter.name),
                    subtitle: Text(reciter.style),
                    trailing: isSelected 
                        ? const Icon(Icons.check, color: AppTheme.goldColor) 
                        : null,
                    selected: isSelected,
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
