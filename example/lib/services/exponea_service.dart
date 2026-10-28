import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/sdk_configuration_snapshot.dart';
import 'package:exponea_example/services/sdk_status_store.dart';
import 'package:exponea/exponea.dart';

/// Abstraction over the Exponea plugin for testability.
abstract class ExponeaService {
  List<String> get logs;

  bool get isConfigured;

  /// Effective SDK configuration snapshot from the last successful configure.
  SdkConfigurationSnapshot? get configurationSnapshot;

  /// Reactive SDK lifecycle state for the toolbar status indicator.
  SdkStatusStore get statusStore;

  /// Runtime in-app content block controller; `null` while the SDK is not configured.
  RuntimeInAppContentBlockController? get inAppContentBlocksController;

  void appendLog(String message);

  void clearLogs();

  Future<void> configure(ConfigureRequest request);

  Future<void> clearLocalCustomerData();

  Future<void> anonymize();

  Future<void> stopIntegration();

  void resetShellState();

  Future<String> fetchConsents();

  Future<String> fetchRecommendation({required String recommendationId});

  Future<String> fetchSegments({String exposingCategory = 'discovery'});

  Future<String> getCustomerCookie();

  Future<void> identifyCustomer({
    required Map<String, String> customerIds,
    Map<String, dynamic> properties = const {},
    bool withAuthToken = false,
  });

  Future<String> setAuthToken();

  Future<void> trackPageView({required String screenName});

  Future<void> trackCustomEvent({
    required String eventType,
    required Map<String, dynamic> properties,
  });

  Future<void> trackDemoPayment();

  Future<bool> requestPushAuthorization();

  Future<void> trackDemoFcmToken();

  Future<void> trackDemoPushDelivered();

  Future<void> trackDemoPushClicked();

  Future<FlushMode> getFlushMode();

  Future<void> setFlushMode(FlushMode mode);

  Future<Duration> getFlushPeriod();

  Future<void> setFlushPeriod(Duration period);

  Future<void> flushData();

  Future<LogLevel> getLogLevel();

  Future<void> setLogLevel(LogLevel level);
}
