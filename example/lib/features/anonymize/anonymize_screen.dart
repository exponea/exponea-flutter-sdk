import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/widgets/stop_integration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnonymizeScreen extends StatefulWidget {
  const AnonymizeScreen({
    super.key,
    required this.onResetToAuth,
  });

  final VoidCallback onResetToAuth;

  @override
  State<AnonymizeScreen> createState() => _AnonymizeScreenState();
}

class _AnonymizeScreenState extends State<AnonymizeScreen> {
  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  bool _busy = false;

  Future<void> _anonymize() async {
    setState(() => _busy = true);
    try {
      await ExponeaServiceScope.of(context).anonymize();
      if (!mounted) {
        return;
      }
      await _showAnonymizedDialog();
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      await _showFailureDialog(
        title: 'Anonymize failed',
        message: error.message,
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _stopIntegration() async {
    final choice = await showStopIntegrationDialog(
      context,
      backToAuthSemanticsId: 'btn_stop_back_to_auth',
      stopAndContinueSemanticsId: 'btn_stop_stop_and_continue',
      cancelSemanticsId: 'btn_stop_cancel',
    );
    if (!mounted) {
      return;
    }
    switch (choice) {
      case StopIntegrationChoice.cancel:
        return;
      case StopIntegrationChoice.backToAuth:
        setState(() => _busy = true);
        final service = ExponeaServiceScope.of(context);
        try {
          await service.stopIntegration();
        } on PlatformException {
          // stopIntegration may report errors when already stopped; treat the
          // SDK as de-integrated regardless.
        } finally {
          if (mounted) {
            setState(() => _busy = false);
          }
        }
        if (!mounted) {
          return;
        }
        widget.onResetToAuth();
      case StopIntegrationChoice.stopAndContinue:
        setState(() => _busy = true);
        final service = ExponeaServiceScope.of(context);
        try {
          await service.stopIntegration();
        } on PlatformException {
          // Treat the SDK as de-integrated regardless.
        } finally {
          if (mounted) {
            setState(() => _busy = false);
          }
        }
        // Stay on this screen — semafor goes red.
    }
  }

  Future<void> _showAnonymizedDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Semantics(
          identifier: 'lbl_anonymized_title',
          child: const Text('Customer anonymized'),
        ),
        content: const Text('Stored customer data cleared.'),
        actions: [
          Semantics(
            identifier: 'btn_anonymized_ok',
            button: true,
            label: 'Ok',
            child: TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Ok'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFailureDialog({
    required String title,
    String? message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: message != null && message.isNotEmpty
            ? Text(message)
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BrandColors.grey100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Card(
          margin: EdgeInsets.zero,
          color: BrandColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: BrandColors.grey300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Anonymize',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Anonymize clears local customer data and starts a new anonymous session. '
                  'Stop Integration de-integrates the SDK.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Semantics(
                  identifier: 'btn_anonymize',
                  button: true,
                  label: 'Anonymize',
                  child: FilledButton(
                    onPressed: _busy ? null : _anonymize,
                    style: FilledButton.styleFrom(
                      backgroundColor: BrandColors.yellow,
                      foregroundColor: BrandColors.black,
                      shape: _buttonShape,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Anonymize'),
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  identifier: 'btn_stop_integration',
                  button: true,
                  label: 'Stop Integration',
                  child: OutlinedButton(
                    onPressed: _busy ? null : _stopIntegration,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: BrandColors.white,
                      foregroundColor: BrandColors.red,
                      disabledForegroundColor:
                          BrandColors.red.withOpacity(0.5),
                      side: const BorderSide(color: BrandColors.red),
                      shape: _buttonShape,
                      minimumSize: const Size.fromHeight(44),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    child: const Text('Stop Integration'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
