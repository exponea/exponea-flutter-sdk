import 'package:exponea/exponea.dart';
import 'package:exponea_example/util/local_jwt_generator.dart';
import 'package:exponea_example/util/sdk_setup_state.dart';
import 'package:flutter/material.dart';

typedef IdentifyCustomerCallback = Future<void> Function(String message);

class IdentifyCustomerDialog extends StatefulWidget {
  final ExponeaPlugin plugin;
  final bool isStreamConfig;

  const IdentifyCustomerDialog({
    super.key,
    required this.plugin,
    required this.isStreamConfig,
  });

  static Future<void> show(
    BuildContext context, {
    required ExponeaPlugin plugin,
    required bool isStreamConfig,
    required IdentifyCustomerCallback onResult,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => IdentifyCustomerDialog(
        plugin: plugin,
        isStreamConfig: isStreamConfig,
      ),
    ).then((_) async {});
  }

  @override
  State<IdentifyCustomerDialog> createState() => _IdentifyCustomerDialogState();
}

class _IdentifyCustomerDialogState extends State<IdentifyCustomerDialog> {
  final _registeredIdController = TextEditingController(
    text: 'test-user-1@test.com',
  );
  var _loading = false;

  @override
  void dispose() {
    _registeredIdController.dispose();
    super.dispose();
  }

  Map<String, String> get _customerIds {
    final registered = _registeredIdController.text.trim();
    if (registered.isEmpty) {
      return {};
    }
    return {'registered': registered};
  }

  Future<void> _identify({required bool withAuthToken}) async {
    final ids = _customerIds;
    if (ids.isEmpty) {
      _showSnack('Registered ID is required.');
      return;
    }

    setState(() => _loading = true);
    try {
      if (withAuthToken) {
        if (!LocalJwtTokenGenerator.instance.isConfigured) {
          _showSnack('JWT generator is not configured.');
          return;
        }
        final token = LocalJwtTokenGenerator.instance.generateToken(ids);
        if (token == null) {
          _showSnack('Failed to generate JWT token.');
          return;
        }
        await widget.plugin.identifyCustomer(
          CustomerIdentity(customerIds: ids, sdkAuthToken: token),
        );
      } else if (widget.isStreamConfig) {
        await widget.plugin.identifyCustomer(
          CustomerIdentity(customerIds: ids),
        );
      } else {
        await widget.plugin.identifyCustomer(Customer(ids: ids));
      }
      SdkSetupState.setCustomerIds(ids);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer identified successfully')),
        );
      }
    } on Exception catch (err) {
      _showSnack('Failed to identify customer: $err');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Identify customer'),
      content: SingleChildScrollView(
        child: TextField(
          controller: _registeredIdController,
          decoration: const InputDecoration(
            labelText: 'Registered ID',
          ),
          enabled: !_loading,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _loading ? null : () => _identify(withAuthToken: false),
          child: const Text('Identify'),
        ),
        if (widget.isStreamConfig)
          TextButton(
            onPressed: _loading ? null : () => _identify(withAuthToken: true),
            child: const Text('Identify with auth token'),
          ),
      ],
    );
  }
}
