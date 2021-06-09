import 'data/model/configuration.dart';
import 'data/model/consent.dart';
import 'data/model/event_type.dart';
import 'data/model/flush_mode.dart';
import 'data/model/log_level.dart';
import 'data/model/project.dart';
import 'data/model/push.dart';
import 'data/model/recommendation.dart';

typedef PushReceivedListener = void Function(Map<String, dynamic> data);

typedef OpenedPushListener = void Function(OpenedPush openedPush);

///
/// Base interface implemented by platforms and plugin.
///
abstract class BaseInterface {
  /// Configure Exponea SDK.
  /// Should only be called once.
  /// You need to configure ExponeaSDK before calling most methods.
  Future<void> configure(ExponeaConfiguration configuration);

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
  Future<void> anonymize({
    ExponeaProject? exponeaProject,
    Map<EventType, List<ExponeaProject>>? mapping,
  });

  /// Identify current customer with new customer ids and properties.
  Future<void> identifyCustomer({
    required Map<String, String> customerIds,
    required Map<String, dynamic> properties,
  });

  /// Flush data to Exponea backend.
  /// Only usable in [FlushMode.manual].
  Future<void> flushData();

  /// Track custom event to Exponea backend.
  Future<void> trackEvent({
    required String eventName,
    required Map<String, dynamic> properties,
    DateTime? timestamp,
  });

  /// Manually track session start.
  /// Only usable when [ExponeaConfiguration.automaticSessionTracking] is disabled.
  Future<void> trackSessionStart(DateTime timestamp);

  /// Manually track session end.
  /// Only usable when [ExponeaConfiguration.automaticSessionTracking] is disabled.
  Future<void> trackSessionEnd(DateTime timestamp);

  /// Fetch consents for the current customer.
  Future<List<Consent>> fetchConsents();

  /// Fetch recommendations based on RecommendationOptions.
  Future<List<Recommendation>> fetchRecommendations(
    RecommendationOptions options,
  );

  /// Set a listener to be called when push notification is opened.
  /// The SDK will hold last [OpenedPush] until you set the listener.
  void setPushOpenedListener(OpenedPushListener listener);

  /// Removes push notification opened listener.
  void removePushOpenedListener();

  /// Set a listener to be called when push notification is received.
  /// Called for both regular and silent push notifications on Android, and silent notifications *only* on iOS.
  /// The SDK will hold last data until you set the listener.
  void setPushReceivedListener(PushReceivedListener listener);

  /// Remove push notification received listener.
  void removePushReceivedListener();

  /// Request push authorization on iOS.
  Future<bool> requestIosPushAuthorization();
}
