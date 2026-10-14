import 'package:exponea_example/features/tracking/tracking_dialog_widgets.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/util/local_jwt_generator.dart';
import 'package:exponea_example/util/sdk_setup_state.dart';
import 'package:exponea_example/widgets/action_feedback.dart';
import 'package:exponea_example/widgets/suite_ok_button.dart';
import 'package:flutter/material.dart';

Future<void> showIdentifyCustomerDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const IdentifyCustomerDialog(),
  );
}

class IdentifyCustomerDialog extends StatefulWidget {
  const IdentifyCustomerDialog({super.key});

  @override
  State<IdentifyCustomerDialog> createState() => _IdentifyCustomerDialogState();
}

class _IdentifyCustomerDialogState extends State<IdentifyCustomerDialog> {
  final _attrNameController = TextEditingController(text: 'registered');
  final _attrValueController = TextEditingController();
  final Map<String, dynamic> _attributes = {};
  bool _loading = false;

  String get _registeredLabel {
    final registered = SdkSetupState.registeredId;
    return registered.isEmpty ? '<not set>' : registered;
  }

  @override
  void dispose() {
    _attrNameController.dispose();
    _attrValueController.dispose();
    super.dispose();
  }

  void _addAttribute() {
    final name = _attrNameController.text.trim();
    final value = _attrValueController.text.trim();
    if (name.isEmpty || value.isEmpty) {
      return;
    }
    setState(() {
      _attributes[name] = value;
      _attrNameController.clear();
      _attrValueController.clear();
    });
  }

  Future<void> _showSuiteAlert(String message) {
    return showSuiteOkAlert(context, message);
  }

  Future<void> _identify({required bool withAuthToken}) async {
    if (withAuthToken && !LocalJwtTokenGenerator.instance.isConfigured) {
      showActionSnackBar(
        context,
        'JWT Key ID and Secret must be provided during configuration.',
      );
      return;
    }

    // Commit typed fields even if Add was not tapped (Appium/IME often fills
    // fields then hits Identify directly).
    final pendingName = _attrNameController.text.trim();
    final pendingValue = _attrValueController.text.trim();
    if (pendingName.isNotEmpty && pendingValue.isNotEmpty) {
      _attributes[pendingName] = pendingValue;
    }

    // Android TrackingViewModel parity: lift attribute key `registered` into
    // customerIds; otherwise keep the previously stored registered id.
    final props = Map<String, dynamic>.from(_attributes);
    final registeredUpdate = props.remove('registered')?.toString().trim();
    var registeredId = registeredUpdate;
    if (registeredId == null || registeredId.isEmpty) {
      registeredId = SdkSetupState.registeredId;
    }
    if (registeredId.isEmpty) {
      showActionSnackBar(context, 'Identify failed: registered ID is required');
      return;
    }

    final customerIds = {'registered': registeredId};
    setState(() => _loading = true);
    try {
      await ExponeaServiceScope.of(context).identifyCustomer(
        customerIds: customerIds,
        properties: props,
        withAuthToken: withAuthToken,
      );
      if (!mounted) {
        return;
      }
      // Shared Appium suite waits for this copy then taps OK
      // (`android.widget.Button[@text="OK"]`), then expects the identify dialog gone.
      await _showSuiteAlert('Customer identified successfully');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        await _showSuiteAlert('Failed to identify customer\n$error');
      }
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
        TrackingDialogWidgets.title('Identify Customer'),
        const SizedBox(height: 8),
        TrackingDialogWidgets.resultPanel(
          text: 'registered: $_registeredLabel',
          semanticsId: 'lbl_registered_id',
        ),
        const SizedBox(height: 12),
        TrackingDialogWidgets.outlineField(
          controller: _attrNameController,
          label: 'Attribute name',
          semanticsId: 'fld_identify_attr_name',
          enabled: !_loading,
        ),
        const SizedBox(height: 8),
        TrackingDialogWidgets.outlineField(
          controller: _attrValueController,
          label: 'Attribute value',
          semanticsId: 'fld_identify_attr_value',
          enabled: !_loading,
        ),
        const SizedBox(height: 8),
        TrackingDialogWidgets.outlinedButton(
          label: 'Add',
          semanticsId: 'btn_identify_add_attr',
          onPressed: _loading ? null : _addAttribute,
        ),
        const SizedBox(height: 12),
        TrackingDialogWidgets.resultPanel(
          text: TrackingDialogWidgets.formatAttributesJson(_attributes),
          minHeight: 80,
          semanticsId: 'lbl_identify_attrs_json',
        ),
        const SizedBox(height: 16),
        TrackingDialogWidgets.filledButton(
          label: 'Identify',
          semanticsId: 'btn_identify',
          onPressed: _loading ? null : () => _identify(withAuthToken: false),
        ),
        if (SdkSetupState.isStreamConfig) ...[
          const SizedBox(height: 8),
          TrackingDialogWidgets.outlinedButton(
            label: 'Identify with auth token',
            semanticsId: 'btn_identify_auth',
            onPressed: _loading ? null : () => _identify(withAuthToken: true),
          ),
        ],
        const SizedBox(height: 8),
        TrackingDialogWidgets.outlinedButton(
          label: 'Cancel',
          semanticsId: 'btn_identify_cancel',
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
