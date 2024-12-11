import '../exponea.dart';

///
/// Base interface implemented by platforms and plugin.
///
abstract class BaseInterface {
  /// Configure Exponea SDK.
  /// Should only be called once.
  /// You need to configure ExponeaSDK before calling most methods.
  /// Returns true if configuration was successful. Returns false if sdk was already configured.
  Future<bool> configure(ExponeaConfiguration configuration);

  /// Check whether Exponea SDK is configured.
  Future<bool> isConfigured();

  /// Get cookie of the current customer.
  Future<String> getCustomerCookie();

  /// Enable automatic push notification diagnostics *before* configuring the SDK to help you with push notification integration.
  Future<void> checkPushSetup();

  /// Get current [FlushMode] used by the SDK.
  Future<FlushMode> getFlushMode();

  /// Set the Flush mode used by the SDK.
  Future<void> setFlushMode(FlushMode mode);

  /// Get the period with which events are tracked to Exponea backend.
  /// Only valid in [FlushMode.period].
  Future<Duration> getFlushPeriod();

  /// Set the period with which events are tracked to Exponea backend.
  /// Only valid in [FlushMode.period].
  Future<void> setFlushPeriod(Duration period);

  /// Get current [LogLevel] native SDK uses.
  Future<LogLevel> getLogLevel();

  /// Set [LogLevel] for native SDK.
  Future<void> setLogLevel(LogLevel level);

  /// Get default properties tracked with every event
  Future<Map<String, dynamic>> getDefaultProperties();

  /// Set default properties tracked with every event.
  /// Only use for reconfiguration, preferred way of setting default properties is configuration object.
  Future<void> setDefaultProperties(Map<String, dynamic> properties);

  /// Anonymize current customer and create a new one.
  /// Push token is cleared on Exponea backend.
  /// Optionally changes default Exponea project and event-project mapping.
  Future<void> anonymize([
    ExponeaConfigurationChange configurationChange =
        const ExponeaConfigurationChange(),
  ]);

  /// Identify current customer with new customer ids and properties.
  Future<void> identifyCustomer(Customer customer);

  /// Flush data to Exponea backend.
  /// Only usable in [FlushMode.manual].
  Future<void> flushData();

  /// Track custom event to Exponea backend.
  Future<void> trackEvent(Event event);

  /// Manually track session start.
  /// Only usable when [ExponeaConfiguration.automaticSessionTracking] is disabled.
  /// NOTE: iOS doesn't support using a specific timestamp.
  Future<void> trackSessionStart({DateTime? timestamp});

  /// Manually track session end.
  /// Only usable when [ExponeaConfiguration.automaticSessionTracking] is disabled.
  /// NOTE: iOS doesn't support using a specific timestamp.
  Future<void> trackSessionEnd({DateTime? timestamp});

  /// Fetch consents for the current customer.
  Future<List<Consent>> fetchConsents();

  /// Fetch recommendations based on RecommendationOptions.
  Future<List<Recommendation>> fetchRecommendations(
    RecommendationOptions options,
  );

  /// A stream of opened push notifications.
  /// The SDK will hold last data until you set the listener.
  /// Don't forget to call cancel on the subscription when no longer listening.
  Stream<OpenedPush> get openedPushStream;

  /// A stream of received push notifications.
  /// Called for both regular and silent push notifications on Android, and silent notifications *only* on iOS.
  /// The SDK will hold last data until you set the listener.
  /// Don't forget to call cancel on the subscription when no longer listening.
  Stream<ReceivedPush> get receivedPushStream;

  /// A stream of In-app message actions.
  /// The SDK will hold last data until you set the listener.
  /// Don't forget to call cancel on the subscription when no longer listening.
  /// If overrideDefaultBehavior is set to true, default in-app action will not be performed ( e.g. deep link )
  /// If trackActions is set to false, click and close in-app events will not be tracked automatically
  Stream<InAppMessageAction> inAppMessageActionStream({bool overrideDefaultBehavior = false, bool trackActions = true});

  /// Request push authorization on Android or iOS.
  Future<bool> requestPushAuthorization();

  /// Request push authorization on iOS.
  @Deprecated("Will be removed in a later version of the SDK, use 'requestPushAuthorization()' instead")
  Future<bool> requestIosPushAuthorization();

  /// Set AppInboxProvider
  Future<void> setAppInboxProvider(AppInboxStyle style);

  /// Track AppInbox message detail opened event
  /// Event is tracked if parameter 'message' has TRUE value of 'hasTrackingConsent' property
  Future<void> trackAppInboxOpened(AppInboxMessage message);

  /// Track AppInbox message detail opened event
  Future<void> trackAppInboxOpenedWithoutTrackingConsent(AppInboxMessage message);

  /// Track AppInbox message click event
  /// Event is tracked if one or both conditions met:
  ///     - parameter 'message' has TRUE value of 'hasTrackingConsent' property
  ///     - parameter 'buttonLink' has TRUE value of query parameter 'xnpe_force_track'
  Future<void> trackAppInboxClick(AppInboxAction action, AppInboxMessage message);

  /// Track AppInbox message click event
  Future<void> trackAppInboxClickWithoutTrackingConsent(AppInboxAction action, AppInboxMessage message);

  /// Marks AppInbox message as read
  Future<bool> markAppInboxAsRead(AppInboxMessage message);

  /// Fetches AppInbox for the current customer
  Future<List<AppInboxMessage>> fetchAppInbox();

  /// Fetches AppInbox message by ID for the current customer
  Future<AppInboxMessage> fetchAppInboxItem(String messageId);

  /// Track in-app content block click event
  Future<void> trackInAppContentBlockClick(String placeholderId, InAppContentBlock contentBlock, InAppContentBlockAction action);

  /// Track in-app content block click event
  Future<void> trackInAppContentBlockClickWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock, InAppContentBlockAction action);

  /// Track in-app content block close event
  Future<void> trackInAppContentBlockClose(String placeholderId, InAppContentBlock contentBlock);

  /// Track in-app content block close event
  Future<void> trackInAppContentBlockCloseWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock);

  /// Track in-app content block show event
  Future<void> trackInAppContentBlockShown(String placeholderId, InAppContentBlock contentBlock);

  /// Track in-app content block show event
  Future<void> trackInAppContentBlockShownWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock);

  /// Track in-app content block error event
  Future<void> trackInAppContentBlockError(String placeholderId, InAppContentBlock contentBlock, String errorMessage);

  /// Track in-app content block error event
  Future<void> trackInAppContentBlockErrorWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock, String errorMessage);
  
  /// Track in-app message click event
  Future<void> trackInAppMessageClick(InAppMessage message, InAppMessageButton button);

  /// Track in-app message click event
  Future<void> trackInAppMessageClickWithoutTrackingConsent(InAppMessage message, InAppMessageButton button);

  /// Track in-app message close event
  Future<void> trackInAppMessageClose(InAppMessage message, {InAppMessageButton? button, bool interaction = true});

  /// Track in-app message close event
  Future<void> trackInAppMessageCloseWithoutTrackingConsent(InAppMessage message, {InAppMessageButton? button, bool interaction = true});

  /// Track payment event.
  Future<void> trackPaymentEvent(PurchasedItem purchasedItem, {DateTime? timestamp});

  /// Track FCM/APNS push token
  Future<void> trackPushToken(String token);

  /// Track HMS push token
  /// Only for Android
  Future<void> trackHmsPushToken(String token);

  /// Handle FCM/APNS push token
  Future<void> handlePushToken(String token);

  /// Handle HMS push token
  /// Only for Android
  Future<void> handleHmsPushToken(String token);

  /// Track clicked push notification
  Future<void> trackClickedPush(Map<String, dynamic> data);

  /// Track clicked push notification
  Future<void> trackClickedPushWithoutTrackingConsent(Map<String, dynamic> data);

  /// Track delivered push notification
  Future<void> trackDeliveredPush(Map<String, dynamic> data);

  /// Track delivered push notification
  Future<void> trackDeliveredPushWithoutTrackingConsent(Map<String, dynamic> data);

  /// Checks if push notifications originate from bloomreach
  Future<bool> isBloomreachNotification(Map<String, String> data);

  /// Handle Campaign click
  Future<void> handleCampaignClick(String url);

  /// Handle push notification Opened
  Future<void> handlePushNotificationOpened(Map<String, dynamic> data);

  /// Handle push notification Opened
  Future<void> handlePushNotificationOpenedWithoutTrackingConsent(Map<String, dynamic> data);
}
