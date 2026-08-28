import 'dart:async';

import 'package:exponea/exponea.dart';
import 'package:exponea_example/util/local_jwt_generator.dart';
import 'package:exponea_example/util/sdk_setup_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reactive Stream JWT refresh for the example app (demo-only).
///
/// Register via [start] before [ExponeaPlugin.configure] so auth errors during
/// init are handled immediately.
class StreamAuthListener {
  StreamAuthListener._();

  static final ExponeaPlugin _plugin = ExponeaPlugin();
  static StreamSubscription<SdkAuthError>? _subscription;

  /// Optional hook for UI feedback (e.g. snackbar on [HomePage]).
  static void Function(SdkAuthError error)? onAuthError;

  static bool get isActive => _subscription != null;

  static void start() {
    _subscription?.cancel();
    _subscription = null;
    if (!LocalJwtTokenGenerator.instance.isConfigured) {
      return;
    }
    _subscription = _plugin.sdkAuthErrorStream.listen(_handleAuthError);
  }

  static void stop() {
    _subscription?.cancel();
    _subscription = null;
    onAuthError = null;
  }

  static Future<void> _handleAuthError(SdkAuthError error) async {
    debugPrint('[Exponea] Auth error: ${error.errorCode}');
    onAuthError?.call(error);

    final ids = SdkSetupState.customerIds;
    if (ids.isEmpty) {
      debugPrint(
        '[Exponea] Customer is not identified, skipping JWT token generation',
      );
      return;
    }

    final token = LocalJwtTokenGenerator.instance.generateToken(ids);
    if (token == null) {
      return;
    }

    try {
      await _plugin.setSdkAuthToken(token);
    } on PlatformException catch (err) {
      debugPrint('[Exponea] Token refresh failed: $err');
    }
  }
}
