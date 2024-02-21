import 'dart:async';

import 'package:exponea/exponea.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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
  Future<void> anonymize([
    ExponeaConfigurationChange configurationChange =
        const ExponeaConfigurationChange(),
  ]) async {
    throw UnimplementedError();
  }

  @override
  Future<void> checkPushSetup() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> configure(ExponeaConfiguration configuration) async {
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
  Future<void> identifyCustomer(Customer customer) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> isConfigured() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestPushAuthorization() async {
    throw UnimplementedError();
  }

  @Deprecated("Will be removed in a later version of the SDK, use 'requestPushAuthorization()' instead")
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
  Future<void> trackEvent(Event event) async {
    throw UnimplementedError();
  }

  @override
  Future<void> trackSessionEnd({DateTime? timestamp}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> trackSessionStart({DateTime? timestamp}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setAppInboxProvider(AppInboxStyle style) async {
    throw UnimplementedError();
  }

  @override
  Future<void> trackAppInboxOpened(AppInboxMessage message) async {
    throw UnimplementedError();
  }

  @override
  Future<void> trackAppInboxOpenedWithoutTrackingConsent(AppInboxMessage message) async {
    throw UnimplementedError();
  }

  @override
  Future<void> trackAppInboxClick(AppInboxAction action, AppInboxMessage message) async {
    throw UnimplementedError();
  }

  @override
  Future<void> trackAppInboxClickWithoutTrackingConsent(AppInboxAction action, AppInboxMessage message) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> markAppInboxAsRead(AppInboxMessage message) async {
    throw UnimplementedError();
  }

  @override
  Future<List<AppInboxMessage>> fetchAppInbox() async {
    throw UnimplementedError();
  }

  @override
  Future<AppInboxMessage> fetchAppInboxItem(String messageId) async {
    throw UnimplementedError();
  }

  @override
  Stream<OpenedPush> get openedPushStream => throw UnimplementedError();

  @override
  Stream<ReceivedPush> get receivedPushStream => throw UnimplementedError();

  @override
  Stream<InAppMessageAction> inAppMessageActionStream({bool overrideDefaultBehavior = false, bool trackActions = true}) => throw UnimplementedError();
}
