import 'package:exponea/src/data/encoder/configuration.dart';
import 'package:flutter/services.dart';

import '../data/model/configuration.dart';
import 'platform_interface.dart';

/// An implementation of [ExponeaPlatform] that uses method channels.
class MethodChannelExponeaPlatform extends ExponeaPlatform {
  static const _channelName = 'com.exponea';
  static const _channel = MethodChannel(_channelName);
  static const _methodConfigure = 'configure';
  static const _methodIsConfigured = 'isConfigured';

  @override
  Future<void> configure(ExponeaConfiguration configuration) async {
    final data = ExponeaConfigurationEncoder.encode(configuration);
    await _channel.invokeMethod(_methodConfigure, data);
  }

  @override
  Future<bool> isConfigured() async {
    return (await _channel.invokeMethod<bool>(_methodIsConfigured))!;
  }
}
