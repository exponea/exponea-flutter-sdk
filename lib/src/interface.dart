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
}
