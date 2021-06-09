import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../data/model/configuration.dart';
import '../data/model/consent.dart';
import '../data/model/event_type.dart';
import '../data/model/flush_mode.dart';
import '../data/model/log_level.dart';
import '../data/model/project.dart';
import '../data/model/recommendation.dart';
import '../interface.dart';
import 'method_channel.dart';

///
/// Handles communication with the platform.
///
abstract class ExponeaPlatform extends PlatformInterface
    implements BaseInterface {
  /// Constructs a [ExponeaPlatform].
  ExponeaPlatform() : super(token: _token);

  static final Object _token = Object();

  static ExponeaPlatform _instance = MethodChannelExponeaPlatform();

  /// The default instance of [ExponeaPlatform] to use.
  ///
  /// Defaults to [MethodChannelExponeaPlatform].
  static ExponeaPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [ExponeaPlatform] when they register themselves.
  static set instance(ExponeaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @override
  Future<void> anonymize({
    ExponeaProject? exponeaProject,
    Map<EventType, List<ExponeaProject>>? mapping,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> checkPushSetup() async {
    throw UnimplementedError();
  }

  @override
  Future<void> configure(ExponeaConfiguration configuration) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Consent>> fetchConsents() async {
    throw UnimplementedError();
  }

  @override
  Future<List<Recommendation>> fetchRecommendations(
      RecommendationOptions options) async {
    throw UnimplementedError();
  }

  @override
  Future<void> flushData() async {
    throw UnimplementedError();
  }

  @override
  Future<String> getCustomerCookie() async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getDefaultProperties() async {
    throw UnimplementedError();
  }

  @override
  Future<FlushMode> getFlushMode() async {
    throw UnimplementedError();
  }

  @override
  Future<Duration> getFlushPeriod() async {
    throw UnimplementedError();
  }

  @override
  Future<LogLevel> getLogLevel() async {
    throw UnimplementedError();
  }

  @override
  Future<void> identifyCustomer({
    required Map<String, String> customerIds,
    required Map<String, dynamic> properties,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> isConfigured() async {
    throw UnimplementedError();
  }

  @override
  void removePushOpenedListener() {
    throw UnimplementedError();
  }

  @override
  void removePushReceivedListener() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestIosPushAuthorization() async {
    throw UnimplementedError();
  }

  @override
  Future<void> setDefaultProperties(Map<String, dynamic> properties) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setFlushMode(FlushMode mode) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setFlushPeriod(Duration period) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setLogLevel(LogLevel level) async {
    throw UnimplementedError();
  }

  @override
  void setPushOpenedListener(OpenedPushListener listener) {
    throw UnimplementedError();
  }

  @override
  void setPushReceivedListener(PushReceivedListener listener) {
    throw UnimplementedError();
  }

  @override
  Future<void> trackEvent({
    required String eventName,
    required Map<String, dynamic> properties,
    DateTime? timestamp,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> trackSessionEnd(DateTime timestamp) async {
    throw UnimplementedError();
  }

  @override
  Future<void> trackSessionStart(DateTime timestamp) async {
    throw UnimplementedError();
  }
}
