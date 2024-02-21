import 'package:exponea/exponea.dart';

import '../interface.dart';

class ExponeaPlugin implements BaseInterface {
  ExponeaPlatform get _platform => ExponeaPlatform.instance;

  @override
  Future<void> anonymize([
    ExponeaConfigurationChange configurationChange =
        const ExponeaConfigurationChange(),
  ]) =>
      _platform.anonymize(configurationChange);

  @override
  Future<void> checkPushSetup() => _platform.checkPushSetup();

  @override
  Future<bool> configure(ExponeaConfiguration configuration) =>
      _platform.configure(configuration);

  @override
  Future<List<Consent>> fetchConsents() => _platform.fetchConsents();

  @override
  Future<List<Recommendation>> fetchRecommendations(
          RecommendationOptions options) =>
      _platform.fetchRecommendations(options);

  @override
  Future<void> flushData() => _platform.flushData();

  @override
  Future<String> getCustomerCookie() => _platform.getCustomerCookie();

  @override
  Future<Map<String, dynamic>> getDefaultProperties() =>
      _platform.getDefaultProperties();

  @override
  Future<FlushMode> getFlushMode() => _platform.getFlushMode();

  @override
  Future<Duration> getFlushPeriod() => _platform.getFlushPeriod();

  @override
  Future<LogLevel> getLogLevel() => _platform.getLogLevel();

  @override
  Future<void> identifyCustomer(Customer customer) =>
      _platform.identifyCustomer(customer);

  @override
  Future<bool> isConfigured() => _platform.isConfigured();

  @override
  Future<bool> requestPushAuthorization() =>
      _platform.requestPushAuthorization();

  @Deprecated("Will be removed in a later version of the SDK, use 'requestPushAuthorization()' instead")
  @override
  Future<bool> requestIosPushAuthorization() =>
      _platform.requestIosPushAuthorization();

  @override
  Future<void> setDefaultProperties(Map<String, dynamic> properties) =>
      _platform.setDefaultProperties(properties);

  @override
  Future<void> setFlushMode(FlushMode mode) => _platform.setFlushMode(mode);

  @override
  Future<void> setFlushPeriod(Duration period) =>
      _platform.setFlushPeriod(period);

  @override
  Future<void> setLogLevel(LogLevel level) => _platform.setLogLevel(level);

  @override
  Future<void> trackEvent(Event event) => _platform.trackEvent(event);

  @override
  Future<void> trackSessionEnd({DateTime? timestamp}) =>
      _platform.trackSessionEnd(timestamp: timestamp);

  @override
  Future<void> trackSessionStart({DateTime? timestamp}) =>
      _platform.trackSessionStart(timestamp: timestamp);

  @override
  Future<void> setAppInboxProvider(AppInboxStyle style) =>
      _platform.setAppInboxProvider(style);

  @override
  Future<void> trackAppInboxOpened(AppInboxMessage message) =>
      _platform.trackAppInboxOpened(message);

  @override
  Future<void> trackAppInboxOpenedWithoutTrackingConsent(
      AppInboxMessage message
  ) =>
      _platform.trackAppInboxOpenedWithoutTrackingConsent(message);

  @override
  Future<void> trackAppInboxClick(
      AppInboxAction action,
      AppInboxMessage message
  ) =>
      _platform.trackAppInboxClick(action, message);

  @override
  Future<void> trackAppInboxClickWithoutTrackingConsent(
      AppInboxAction action,
      AppInboxMessage message
  ) =>
      _platform.trackAppInboxClickWithoutTrackingConsent(action, message);

  @override
  Future<bool> markAppInboxAsRead(AppInboxMessage message) =>
      _platform.markAppInboxAsRead(message);

  @override
  Future<List<AppInboxMessage>> fetchAppInbox() => _platform.fetchAppInbox();

  @override
  Future<AppInboxMessage> fetchAppInboxItem(String messageId) =>
      _platform.fetchAppInboxItem(messageId);

  @override
  Stream<OpenedPush> get openedPushStream => _platform.openedPushStream;

  @override
  Stream<ReceivedPush> get receivedPushStream => _platform.receivedPushStream;

  @override
  Stream<InAppMessageAction> inAppMessageActionStream({bool overrideDefaultBehavior = false, bool trackActions = true}) =>
      _platform.inAppMessageActionStream(overrideDefaultBehavior: overrideDefaultBehavior, trackActions : trackActions);
}
