import 'package:flutter/material.dart';

/// Transient action confirmation matching Android v2 Snackbar behaviour.
void showActionSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
