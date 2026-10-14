import 'package:flutter/material.dart';

/// Appium suite dismiss control: iOS `accessibility_id=OK`, Android `@text=OK`.
///
/// XCUITest often **activates** the Semantics node rather than hit-testing the
/// TextButton, so [onPressed] is wired to both `onTap` and the button.
class SuiteOkButton extends StatelessWidget {
  const SuiteOkButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'OK',
      button: true,
      value: 'OK',
      excludeSemantics: true,
      onTap: onPressed,
      child: TextButton(
        onPressed: onPressed,
        child: const Text('OK'),
      ),
    );
  }
}

/// Blocking suite alert dismissed via [SuiteOkButton].
Future<void> showSuiteOkAlert(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      content: Text(message),
      actions: [
        SuiteOkButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
      ],
    ),
  );
}
