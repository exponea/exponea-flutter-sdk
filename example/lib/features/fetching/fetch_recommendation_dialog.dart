import 'package:exponea_example/features/fetching/recommendation_preferences.dart';
import 'package:flutter/material.dart';

Future<String?> showFetchRecommendationDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const FetchRecommendationDialog(),
  );
}

class FetchRecommendationDialog extends StatefulWidget {
  const FetchRecommendationDialog({super.key});

  @override
  State<FetchRecommendationDialog> createState() =>
      _FetchRecommendationDialogState();
}

class _FetchRecommendationDialogState extends State<FetchRecommendationDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedId();
  }

  Future<void> _loadSavedId() async {
    final savedId = await RecommendationPreferences.loadId();
    if (!mounted || savedId.isEmpty) {
      return;
    }
    setState(() => _controller.text = savedId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final id = _controller.text.trim();
    if (id.isEmpty) {
      return;
    }
    await RecommendationPreferences.saveId(id);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fetch recommendation'),
      content: Semantics(
        identifier: 'fld_recommendation_id',
        textField: true,
        label: 'Recommendation id',
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Recommendation id',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
      actions: [
        Semantics(
          identifier: 'btn_recommendation_dialog_cancel',
          button: true,
          label: 'Cancel',
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        Semantics(
          identifier: 'btn_recommendation_dialog_fetch',
          button: true,
          label: 'Fetch recommendation',
          enabled: _controller.text.trim().isNotEmpty,
          child: TextButton(
            onPressed:
                _controller.text.trim().isEmpty ? null : _submit,
            child: const Text('Fetch'),
          ),
        ),
      ],
    );
  }
}
