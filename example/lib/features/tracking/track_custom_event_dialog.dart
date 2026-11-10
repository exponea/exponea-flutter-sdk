import 'package:exponea_example/features/tracking/in_app_message_presets.dart';
import 'package:exponea_example/features/tracking/tracking_dialog_widgets.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/widgets/action_feedback.dart';
import 'package:flutter/material.dart';

Future<void> showTrackCustomEventDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const TrackCustomEventDialog(),
  );
}

class TrackCustomEventDialog extends StatefulWidget {
  const TrackCustomEventDialog({super.key});

  @override
  State<TrackCustomEventDialog> createState() => _TrackCustomEventDialogState();
}

class _TrackCustomEventDialogState extends State<TrackCustomEventDialog> {
  final _eventNameController = TextEditingController(text: 'custom_demo_event');
  final _attrNameController = TextEditingController();
  final _attrValueController = TextEditingController();
  final Map<String, dynamic> _properties = {'property': 'some value'};
  InAppMessagePreset? _selectedPreset;
  bool _loading = false;

  @override
  void dispose() {
    _eventNameController.dispose();
    _attrNameController.dispose();
    _attrValueController.dispose();
    super.dispose();
  }

  void _applyPreset(InAppMessagePreset? preset) {
    setState(() {
      _selectedPreset = preset;
      if (preset != null) {
        _eventNameController.text = preset.eventName;
        _properties
          ..clear()
          ..addAll(preset.properties);
      }
    });
  }

  void _addProperty() {
    final name = _attrNameController.text.trim();
    final value = _attrValueController.text.trim();
    if (name.isEmpty || value.isEmpty) {
      return;
    }
    setState(() {
      _properties[name] = value;
      _attrNameController.clear();
      _attrValueController.clear();
    });
  }

  Future<void> _track() async {
    final eventName = _eventNameController.text.trim().isEmpty
        ? 'custom_demo_event'
        : _eventNameController.text.trim();
    setState(() => _loading = true);
    try {
      await ExponeaServiceScope.of(context).trackCustomEvent(
        eventType: eventName,
        properties: Map<String, dynamic>.from(_properties),
      );
      if (mounted) {
        showActionSnackBar(context, 'Custom event tracked: $eventName');
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) showActionSnackBar(context, 'Track event failed: $error');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrackingDialogWidgets.dialogShell(
      children: [
        TrackingDialogWidgets.title('Track Custom Event'),
        const SizedBox(height: 12),
        TrackingDialogWidgets.presetDropdown(
          value: _selectedPreset,
          onSelected: _loading ? (_) {} : _applyPreset,
        ),
        const SizedBox(height: 8),
        TrackingDialogWidgets.outlineField(
          controller: _eventNameController,
          label: 'Event name',
          semanticsId: 'fld_event_name',
          enabled: !_loading,
          readOnly: _selectedPreset != null,
        ),
        const SizedBox(height: 8),
        TrackingDialogWidgets.outlineField(
          controller: _attrNameController,
          label: 'Attribute name',
          semanticsId: 'fld_event_attr_name',
          enabled: !_loading,
        ),
        const SizedBox(height: 8),
        TrackingDialogWidgets.outlineField(
          controller: _attrValueController,
          label: 'Attribute value',
          semanticsId: 'fld_event_attr_value',
          enabled: !_loading,
        ),
        const SizedBox(height: 8),
        TrackingDialogWidgets.outlinedButton(
          label: 'Add',
          semanticsId: 'btn_event_add_attr',
          onPressed: _loading ? null : _addProperty,
        ),
        const SizedBox(height: 12),
        TrackingDialogWidgets.resultPanel(
          text: TrackingDialogWidgets.formatAttributesJson(_properties),
          minHeight: 80,
          semanticsId: 'lbl_event_props_json',
        ),
        const SizedBox(height: 16),
        TrackingDialogWidgets.filledButton(
          label: 'Track',
          semanticsId: 'btn_track_event',
          onPressed: _loading ? null : _track,
        ),
        const SizedBox(height: 8),
        TrackingDialogWidgets.outlinedButton(
          label: 'Cancel',
          semanticsId: 'btn_track_event_cancel',
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
