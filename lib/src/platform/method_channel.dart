import 'package:flutter/services.dart';

import '../data/encoder/configuration.dart';
import '../data/encoder/main.dart';
import '../data/model/configuration.dart';
import '../data/model/configuration_change.dart';
import '../data/model/consent.dart';
import '../data/model/customer.dart';
import '../data/model/event.dart';
import '../data/model/flush_mode.dart';
import '../data/model/log_level.dart';
import '../data/model/push_opened.dart';
import '../data/model/push_received.dart';
import '../data/model/recommendation.dart';
import '../data/util/object.dart';
import 'platform_interface.dart';

/// An implementation of [ExponeaPlatform] that uses method channels.
class MethodChannelExponeaPlatform extends ExponeaPlatform {
  static const _channelName = 'com.exponea';
  static const _channel = MethodChannel(_channelName);

  static const _openedPushStreamName = "$_channelName/opened_push";
  static const _openedPushEventChannel = EventChannel(_openedPushStreamName);

  static const _receivedPushStreamName = "$_channelName/received_push";
  static const _receivedPushEventChannel =
      EventChannel(_receivedPushStreamName);

  static const _methodConfigure = 'configure';
  static const _methodIsConfigured = 'isConfigured';
  static const _methodGetCustomerCookie = 'getCustomerCookie';
  static const _methodIdentifyCustomer = 'identifyCustomer';
  static const _methodAnonymize = 'anonymize';
  static const _methodGetDefaultProperties = 'getDefaultProperties';
  static const _methodSetDefaultProperties = 'setDefaultProperties';
  static const _methodFlush = 'flush';
  static const _methodGetFlushMode = 'getFlushMode';
  static const _methodSetFlushMode = 'setFlushMode';
  static const _methodGetFlushPeriod = 'getFlushPeriod';
  static const _methodSetFlushPeriod = 'setFlushPeriod';
  static const _methodTrackEvent = 'trackEvent';
  static const _methodTrackSessionStart = 'trackSessionStart';
  static const _methodTrackSessionEnd = 'trackSessionEnd';
  static const _methodFetchConsents = 'fetchConsents';
  static const _methodFetchRecommendations = 'fetchRecommendations';
  static const _methodGetLogLevel = 'getLogLevel';
  static const _methodSetLogLevel = 'setLogLevel';
  static const _methodCheckPushSetup = 'checkPushSetup';
  static const _methodRequestPushAuthorization = 'requestPushAuthorization';

  Stream<OpenedPush>? _openedPushStream;
  Stream<ReceivedPush>? _receivedPushStream;

  @override
  Future<void> configure(ExponeaConfiguration configuration) async {
    final data = ExponeaConfigurationEncoder.encode(configuration);
    await _channel.invokeMethod(_methodConfigure, data);
  }

  @override
  Future<bool> isConfigured() async {
    return (await _channel.invokeMethod<bool>(_methodIsConfigured))!;
  }

  @override
  Future<String> getCustomerCookie() async {
    return (await _channel.invokeMethod<String>(_methodGetCustomerCookie))!;
  }

  @override
  Future<void> identifyCustomer(Customer customer) async {
    final data = CustomerEncoder.encode(customer);
    await _channel.invokeMethod<void>(_methodIdentifyCustomer, data);
  }

  @override
  Future<void> anonymize([
    ExponeaConfigurationChange configChange =
        const ExponeaConfigurationChange(),
  ]) async {
    final data = ExponeaConfigurationChangeEncoder.encode(configChange);
    await _channel.invokeMethod<void>(_methodAnonymize, data);
  }

  @override
  Future<Map<String, dynamic>> getDefaultProperties() async {
    return (await _channel
        .invokeMapMethod<String, dynamic>(_methodGetDefaultProperties))!;
  }

  @override
  Future<void> setDefaultProperties(Map<String, dynamic> properties) async {
    await _channel.invokeMethod<void>(_methodSetDefaultProperties, properties);
  }

  @override
  Future<void> flushData() async {
    await _channel.invokeMethod<void>(_methodFlush);
  }

  @override
  Future<FlushMode> getFlushMode() async {
    final data = (await _channel.invokeMethod<String>(_methodGetFlushMode))!;
    return FlushModeEncoder.decode(data);
  }

  @override
  Future<void> setFlushMode(FlushMode mode) async {
    final data = FlushModeEncoder.encode(mode);
    await _channel.invokeMethod<void>(_methodSetFlushMode, data);
  }

  @override
  Future<Duration> getFlushPeriod() async {
    final data = (await _channel.invokeMethod<int>(_methodGetFlushPeriod))!;
    return DurationEncoder.decode(data);
  }

  @override
  Future<void> setFlushPeriod(Duration period) async {
    final data = DurationEncoder.encode(period);
    await _channel.invokeMethod<void>(_methodSetFlushPeriod, data);
  }

  @override
  Future<void> trackEvent(Event event) async {
    final data = EventEncoder.encode(event);
    await _channel.invokeMethod<void>(_methodTrackEvent, data);
  }

  @override
  Future<void> trackSessionStart({DateTime? timestamp}) async {
    final data = timestamp?.let(DateTimeEncoder.encode);
    await _channel.invokeMethod<void>(_methodTrackSessionStart, data);
  }

  @override
  Future<void> trackSessionEnd({DateTime? timestamp}) async {
    final data = timestamp?.let(DateTimeEncoder.encode);
    await _channel.invokeMethod<void>(_methodTrackSessionEnd, data);
  }

  @override
  Future<List<Consent>> fetchConsents() async {
    final outData =
        (await _channel.invokeListMethod<Map>(_methodFetchConsents))!;
    final res =
        outData.map((it) => ConsentEncoder.decode(it)).toList(growable: false);
    return res;
  }

  @override
  Future<List<Recommendation>> fetchRecommendations(
    RecommendationOptions options,
  ) async {
    const method = _methodFetchRecommendations;
    final inData = RecommendationOptionsEncoder.encode(options);
    final outData = (await _channel.invokeListMethod<Map>(method, inData))!;
    final res = outData
        .map((it) => RecommendationEncoder.decode(it))
        .toList(growable: false);
    return res;
  }

  Stream<OpenedPush> get openedPushStream {
    if (_openedPushStream == null) {
      _openedPushStream = _openedPushEventChannel
          .receiveBroadcastStream()
          .cast<Map<dynamic, dynamic>>()
          .map((event) => OpenedPushEncoder.decode(event));
    }
    return _openedPushStream!;
  }

  Stream<ReceivedPush> get receivedPushStream {
    if (_receivedPushStream == null) {
      _receivedPushStream = _receivedPushEventChannel
          .receiveBroadcastStream()
          .cast<Map<dynamic, dynamic>>()
          .map((event) => ReceivedPushEncoder.decode(event));
    }
    return _receivedPushStream!;
  }

  @override
  Future<void> checkPushSetup() async {
    await _channel.invokeMethod<void>(_methodCheckPushSetup);
  }

  @override
  Future<bool> requestIosPushAuthorization() async {
    return (await _channel
        .invokeMethod<bool>(_methodRequestPushAuthorization))!;
  }

  @override
  Future<LogLevel> getLogLevel() async {
    final data = (await _channel.invokeMethod<String>(_methodGetLogLevel))!;
    return LogLevelEncoder.decode(data);
  }

  @override
  Future<void> setLogLevel(LogLevel level) async {
    final data = LogLevelEncoder.encode(level);
    await _channel.invokeMethod<void>(_methodSetLogLevel, data);
  }
}
