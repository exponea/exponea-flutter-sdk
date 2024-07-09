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
  Future<void> trackInAppContentBlockClick(String placeholderId, InAppContentBlock contentBlock, InAppContentBlockAction action) =>
      _platform.trackInAppContentBlockClick(placeholderId, contentBlock, action);

  @override
  Future<void> trackInAppContentBlockClickWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock, InAppContentBlockAction action) =>
      _platform.trackInAppContentBlockClickWithoutTrackingConsent(placeholderId, contentBlock, action);

  @override
  Future<void> trackInAppContentBlockClose(String placeholderId, InAppContentBlock contentBlock) =>
      _platform.trackInAppContentBlockClose(placeholderId, contentBlock);

  @override
  Future<void> trackInAppContentBlockCloseWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock) =>
      _platform.trackInAppContentBlockCloseWithoutTrackingConsent(placeholderId, contentBlock);

  @override
  Future<void> trackInAppContentBlockShown(String placeholderId, InAppContentBlock contentBlock) =>
      _platform.trackInAppContentBlockShown(placeholderId, contentBlock);

  @override
  Future<void> trackInAppContentBlockShownWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock) =>
      _platform.trackInAppContentBlockShownWithoutTrackingConsent(placeholderId, contentBlock);

  @override
  Future<void> trackInAppContentBlockError(String placeholderId, InAppContentBlock contentBlock, String errorMessage) =>
      _platform.trackInAppContentBlockError(placeholderId, contentBlock, errorMessage);

  @override
  Future<void> trackInAppContentBlockErrorWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock, String errorMessage) =>
      _platform.trackInAppContentBlockErrorWithoutTrackingConsent(placeholderId, contentBlock, errorMessage);

  @override    
  Future<void> trackInAppMessageClick(InAppMessage message, InAppMessageButton button) =>
      _platform.trackInAppMessageClick(message, button);

  @override
  Future<void> trackInAppMessageClickWithoutTrackingConsent(InAppMessage message, InAppMessageButton button) =>
      _platform.trackInAppMessageClickWithoutTrackingConsent(message, button);

  @override
  Future<void> trackInAppMessageClose(InAppMessage message, {bool interaction = true}) =>
      _platform.trackInAppMessageClose(message, interaction: interaction);

  @override
  Future<void> trackInAppMessageCloseWithoutTrackingConsent(InAppMessage message, {bool interaction = true}) =>
      _platform.trackInAppMessageCloseWithoutTrackingConsent(message, interaction: interaction);

  @override
  Future<void> trackPaymentEvent(PurchasedItem purchasedItem, {DateTime? timestamp}) =>
      _platform.trackPaymentEvent(purchasedItem, timestamp: timestamp);

  @override
  Future<void> trackPushToken(String token) => _platform.trackPushToken(token);

  @override
  Future<void> trackHmsPushToken(String token) => _platform.trackHmsPushToken(token);

  @override
  Future<void> handlePushToken(String token) => _platform.handlePushToken(token);

  @override
  Future<void> handleHmsPushToken(String token) => _platform.handleHmsPushToken(token);

  @override
  Future<void> trackClickedPush(Map<String, dynamic> data) => _platform.trackClickedPush(data);

  @override
  Future<void> trackClickedPushWithoutTrackingConsent(Map<String, dynamic> data) =>
      _platform.trackClickedPushWithoutTrackingConsent(data);

  @override
  Future<void> trackDeliveredPush(Map<String, dynamic> data) => _platform.trackDeliveredPush(data);

  @override
  Future<void> trackDeliveredPushWithoutTrackingConsent(Map<String, dynamic> data) =>
      _platform.trackDeliveredPushWithoutTrackingConsent(data);

  @override
  Future<bool> isBloomreachNotification(Map<String, String> data) => _platform.isBloomreachNotification(data);

  @override
  Future<void> handleCampaignClick(String url) => _platform.handleCampaignClick(url);

  @override
  Stream<OpenedPush> get openedPushStream => _platform.openedPushStream;

  @override
  Stream<ReceivedPush> get receivedPushStream => _platform.receivedPushStream;

  @override
  Stream<InAppMessageAction> inAppMessageActionStream({bool overrideDefaultBehavior = false, bool trackActions = true}) =>
      _platform.inAppMessageActionStream(overrideDefaultBehavior: overrideDefaultBehavior, trackActions : trackActions);

  @override
  Future<void> handlePushNotificationOpened(Map<String, dynamic> data) =>
      _platform.handlePushNotificationOpened(data);

  @override
  Future<void> handlePushNotificationOpenedWithoutTrackingConsent(Map<String, dynamic> data) =>
      _platform.handlePushNotificationOpenedWithoutTrackingConsent(data);

}
