import 'dart:async';

import 'package:exponea_example/navigation/deeplink_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Host ↔ Dart bridge for incoming VIEW intents / URL opens.
class DeeplinkBridge {
  DeeplinkBridge({
    MethodChannel? channel,
    void Function(DeeplinkAction action)? onAction,
  })  : _channel = channel ?? const MethodChannel('exponea_example/deeplinks'),
        _onAction = onAction;

  final MethodChannel _channel;
  final void Function(DeeplinkAction action)? _onAction;
  bool _listening = false;

  void startListening() {
    if (_listening) {
      return;
    }
    _listening = true;
    _channel.setMethodCallHandler(_handleCall);
    unawaited(_emitInitial());
  }

  void stopListening() {
    if (!_listening) {
      return;
    }
    _listening = false;
    _channel.setMethodCallHandler(null);
  }

  Future<void> _emitInitial() async {
    try {
      final raw = await _channel.invokeMethod<String>('getInitialLink');
      _dispatch(raw);
    } on MissingPluginException {
      // Widget tests / hosts without the channel.
    } on PlatformException catch (error) {
      debugPrint('DeeplinkBridge getInitialLink failed: $error');
    }
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'linkOpened':
        _dispatch(call.arguments is String ? call.arguments as String : null);
        return null;
      default:
        throw MissingPluginException(call.method);
    }
  }

  void _dispatch(String? raw) {
    final action = DeeplinkResolver.resolveRaw(raw);
    if (action == null) {
      return;
    }
    _onAction?.call(action);
  }
}
