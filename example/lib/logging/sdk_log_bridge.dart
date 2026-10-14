import 'dart:async';

import 'package:exponea_example/logging/log_record.dart';
import 'package:exponea_example/logging/sdk_log_store.dart';
import 'package:exponea_example/util/test_environment.dart';
import 'package:flutter/services.dart';

abstract final class SdkLogBridge {
  static const eventChannel = EventChannel('exponea_example/sdk_logs');
  static const controlChannel = MethodChannel('exponea_example/sdk_logs_control');

  static StreamSubscription<dynamic>? _subscription;

  static void connect(SdkLogStore store) {
    if (isFlutterWidgetTest) {
      return;
    }
    _subscription?.cancel();
    _subscription = eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          store.add(LogRecord.fromMap(event));
        }
      },
      onError: (_) {},
    );
  }

  static Future<void> clearNative() async {
    if (isFlutterWidgetTest) {
      return;
    }
    try {
      await controlChannel.invokeMethod<void>('clear');
    } on PlatformException {
      // Native bridge unavailable in some test/device setups.
    }
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
