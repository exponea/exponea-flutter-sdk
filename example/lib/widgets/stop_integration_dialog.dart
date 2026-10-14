import 'package:flutter/material.dart';

/// Result of the stop-integration confirmation dialog.
enum StopIntegrationChoice {
  /// Stop the SDK and navigate back to the authentication screen.
  backToAuth,

  /// Stop the SDK but remain on the current shell screen (intentionally broken state).
  stopAndContinue,

  /// Dismiss the dialog — SDK stays integrated and nothing changes.
  cancel,
}

/// Confirmation dialog shown BEFORE stopping SDK integration (Reset / Stop
/// Integration). The SDK is only de-integrated after the user confirms.
///
/// Returns [StopIntegrationChoice.backToAuth] when the user wants to stop and
/// navigate to auth, [StopIntegrationChoice.stopAndContinue] when the user
/// wants to stop the SDK but remain on the current screen (intentionally broken
/// state), or [StopIntegrationChoice.cancel] when the user dismisses without
/// change.
///
/// [backToAuthSemanticsId], [stopAndContinueSemanticsId] and [cancelSemanticsId]
/// differ by entry point (reset vs stop integration) for automation contract
/// coverage.
Future<StopIntegrationChoice> showStopIntegrationDialog(
  BuildContext context, {
  required String backToAuthSemanticsId,
  required String stopAndContinueSemanticsId,
  required String cancelSemanticsId,
}) async {
  final result = await showDialog<StopIntegrationChoice>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Stop integration?'),
      content: const Text(
        'This de-integrates the SDK. Choose Back to Auth to stop the SDK and '
        're-configure, Stop & Continue to stop the SDK and remain on this '
        'screen (broken state), or Cancel to keep the current session.',
      ),
      actions: [
        Semantics(
          identifier: backToAuthSemanticsId,
          button: true,
          label: 'Back to Auth',
          child: TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(StopIntegrationChoice.backToAuth),
            child: const Text('Back to Auth'),
          ),
        ),
        Semantics(
          identifier: stopAndContinueSemanticsId,
          button: true,
          label: 'Stop & Continue',
          child: TextButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(StopIntegrationChoice.stopAndContinue),
            child: const Text('Stop & Continue'),
          ),
        ),
        Semantics(
          identifier: cancelSemanticsId,
          button: true,
          label: 'Cancel',
          child: TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(StopIntegrationChoice.cancel),
            child: const Text('Cancel'),
          ),
        ),
      ],
    ),
  );
  return result ?? StopIntegrationChoice.cancel;
}
