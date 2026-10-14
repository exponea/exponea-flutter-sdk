import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/sdk_configuration_snapshot.dart';
import 'package:exponea_example/services/exponea_service.dart';
import 'package:exponea_example/services/sdk_status_store.dart';
import 'package:exponea_example/util/local_jwt_generator.dart';
import 'package:exponea_example/util/sdk_setup_state.dart';
import 'package:exponea/exponea.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FakeExponeaService implements ExponeaService {
  FakeExponeaService() {
    appendLog('FakeExponeaService initialized');
  }

  final List<String> _logs = [];
  final SdkStatusStore _statusStore = SdkStatusStore();
  bool _configured = false;
  ConfigureRequest? lastConfigureRequest;
  SdkConfigurationSnapshot? _configurationSnapshot;

  /// When set, the next [stopIntegration] call throws this error, simulating
  /// the native "Exponea SDK is not configured" race the plugin can hit.
  PlatformException? stopIntegrationError;

  FlushMode _flushMode = FlushMode.immediate;
  Duration _flushPeriod = const Duration(seconds: 30);
  LogLevel _logLevel = LogLevel.warning;

  @override
  List<String> get logs => List.unmodifiable(_logs);

  @override
  bool get isConfigured => _configured;

  @override
  SdkConfigurationSnapshot? get configurationSnapshot => _configurationSnapshot;

  @override
  SdkStatusStore get statusStore => _statusStore;

  @override
  void appendLog(String message) {
    _logs.add(message);
  }

  @override
  void clearLogs() {
    _logs.clear();
  }

  @override
  Future<void> configure(ConfigureRequest request) async {
    lastConfigureRequest = request;
    _configured = true;
    SdkSetupState.setStreamConfig(request.mode);
    if (request.customerId.isNotEmpty) {
      SdkSetupState.setCustomerIds({'registered': request.customerId});
      SdkSetupState.isCustomerIdentified = true;
      _statusStore.set(SdkLifecycleState.identified);
    } else {
      _statusStore.set(SdkLifecycleState.anonymous);
    }
    _flushMode = FlushMode.immediate;
    _configurationSnapshot = SdkConfigurationSnapshot(
      tokenTrackFrequency: formatTokenTrackFrequency(TokenFrequency.onTokenChange),
      applicationId: SdkConfigurationSnapshot.resolveApplicationId(
        request.applicationId.isEmpty ? null : request.applicationId,
      ),
    );
    appendLog('Fake configure (${request.mode.name})');
  }

  @override
  Future<void> clearLocalCustomerData() async {
    SdkSetupState.reset();
    _statusStore.set(SdkLifecycleState.anonymous);
    appendLog('Local customer data cleared');
  }

  @override
  Future<void> anonymize() async {
    SdkSetupState.reset();
    _statusStore.set(SdkLifecycleState.anonymous);
    appendLog('Fake anonymize — customer anonymized');
  }

  @override
  Future<void> stopIntegration() async {
    final error = stopIntegrationError;
    try {
      if (error != null) {
        stopIntegrationError = null;
        appendLog('Stop integration failed: ${error.message}');
        throw error;
      }
      appendLog('SDK integration stopped');
    } finally {
      // Mirror PluginExponeaService: the service is always left
      // de-integrated, even when the native call reports an error.
      _configured = false;
      SdkSetupState.reset();
      _configurationSnapshot = null;
      _statusStore.set(SdkLifecycleState.notInitialized);
    }
  }

  @override
  void resetShellState() {
    clearLogs();
  }

  @override
  Future<String> fetchConsents() async {
    appendLog('Fake fetchConsents');
    return '[Consent{category: newsletter, action: accept}]';
  }

  @override
  Future<String> fetchRecommendation({required String recommendationId}) async {
    appendLog('Fake fetchRecommendation($recommendationId)');
    return '[Recommendation{recommendationId: $recommendationId, itemId: demo-item}]';
  }

  @override
  Future<String> fetchSegments({String exposingCategory = 'discovery'}) async {
    appendLog('Fake fetchSegments($exposingCategory)');
    return 'Segments ($exposingCategory):\n[{segment: demo-segment}]';
  }

  @override
  Future<String> getCustomerCookie() async {
    appendLog('Fake getCustomerCookie');
    return _configured ? 'fake-customer-cookie' : '';
  }

  @override
  Future<void> identifyCustomer({
    required Map<String, String> customerIds,
    Map<String, dynamic> properties = const {},
    bool withAuthToken = false,
  }) async {
    SdkSetupState.setCustomerIds(customerIds);
    SdkSetupState.isCustomerIdentified = true;
    _statusStore.set(SdkLifecycleState.identified);
    appendLog(
      'Fake identifyCustomer($customerIds, withAuthToken: $withAuthToken)',
    );
  }

  @override
  Future<String> setAuthToken() async {
    if (!LocalJwtTokenGenerator.instance.isConfigured) {
      appendLog('Set auth token: JWT not configured');
      return 'JWT not configured (set Key ID + Secret in Auth screen)';
    }
    if (!SdkSetupState.isCustomerIdentified) {
      appendLog('Set auth token: customer not identified');
      return 'Identify a customer first';
    }
    appendLog('Fake setSdkAuthToken');
    return 'Auth token set';
  }

  @override
  Future<void> trackPageView({required String screenName}) async {
    appendLog('Fake trackPageView($screenName)');
  }

  @override
  Future<void> trackCustomEvent({
    required String eventType,
    required Map<String, dynamic> properties,
  }) async {
    appendLog('Fake trackEvent($eventType, $properties)');
  }

  @override
  Future<void> trackDemoPayment() async {
    appendLog('Fake trackPaymentEvent(99 USD demo_item)');
  }

  @override
  Future<bool> requestPushAuthorization() async {
    appendLog('Fake requestPushAuthorization');
    return true;
  }

  @override
  Future<void> trackDemoFcmToken() async {
    appendLog('Fake trackPushToken(demo-fcm-token)');
  }

  @override
  Future<void> trackDemoPushDelivered() async {
    appendLog('Fake trackDeliveredPush(campaign_id=demo)');
  }

  @override
  Future<void> trackDemoPushClicked() async {
    appendLog('Fake trackClickedPush(campaign_id=demo)');
  }

  @override
  Future<FlushMode> getFlushMode() async {
    appendLog('Fake getFlushMode');
    return _flushMode;
  }

  @override
  Future<void> setFlushMode(FlushMode mode) async {
    _flushMode = mode;
    appendLog('Fake setFlushMode($mode)');
  }

  @override
  Future<Duration> getFlushPeriod() async {
    appendLog('Fake getFlushPeriod');
    if (_flushMode != FlushMode.period) {
      throw PlatformException(
        code: 'error',
        message: 'Flush mode is not periodic.',
      );
    }
    return _flushPeriod;
  }

  @override
  Future<void> setFlushPeriod(Duration period) async {
    if (_flushMode != FlushMode.period) {
      throw PlatformException(
        code: 'error',
        message: 'Flush mode is not periodic.',
      );
    }
    _flushPeriod = period;
    appendLog('Fake setFlushPeriod($period)');
  }

  @override
  Future<void> flushData() async {
    if (defaultTargetPlatform == TargetPlatform.android &&
        _flushMode != FlushMode.manual) {
      throw PlatformException(
        code: 'error',
        message: 'Flush mode is not manual.',
      );
    }
    appendLog('Fake flushData — queued SDK data sent to backend');
  }

  @override
  Future<LogLevel> getLogLevel() async {
    appendLog('Fake getLogLevel');
    return _logLevel;
  }

  @override
  Future<void> setLogLevel(LogLevel level) async {
    _logLevel = level;
    appendLog('Fake setLogLevel($level)');
  }
}
