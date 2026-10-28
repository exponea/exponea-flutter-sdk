import 'dart:async';
import 'dart:io';

import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/models/sdk_configuration_snapshot.dart';
import 'package:exponea_example/services/exponea_service.dart';
import 'package:exponea_example/services/sdk_status_store.dart';
import 'package:exponea_example/util/app_inbox_style.dart';
import 'package:exponea_example/util/customer_token_ids.dart';
import 'package:exponea_example/util/local_jwt_generator.dart';
import 'package:exponea_example/util/sdk_setup_state.dart';
import 'package:exponea_example/util/stream_auth_listener.dart';
import 'package:exponea/exponea.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _segmentsFetchTimeout = Duration(seconds: 15);

/// Segmentation categories logged by the listeners (same as the Android example app).
const segmentationListenerCategories = ['discovery', 'content', 'merchandising'];

const _deviceChannel = MethodChannel('exponea_example/device');

/// The iOS simulator has no APNs token, so the push self-check always fails there and its
/// alert covers the whole app. The check only runs where push can actually work.
/// Asks the host (compile-time check): `SIMULATOR_*` env vars are missing after an XCTest relaunch.
Future<bool> _isIosSimulator() async {
  if (!Platform.isIOS) {
    return false;
  }
  try {
    return await _deviceChannel.invokeMethod<bool>('isSimulator') ?? false;
  } on MissingPluginException {
    return false;
  }
}

class PluginExponeaService implements ExponeaService {
  PluginExponeaService() : _plugin = ExponeaPlugin();

  final ExponeaPlugin _plugin;
  final List<String> _logs = [];
  final SdkStatusStore _statusStore = SdkStatusStore();
  bool _configured = false;
  SdkConfigurationSnapshot? _configurationSnapshot;
  final List<StreamSubscription<dynamic>> _listenerSubscriptions = [];

  @override
  List<String> get logs => List.unmodifiable(_logs);

  @override
  bool get isConfigured => _configured;

  @override
  SdkConfigurationSnapshot? get configurationSnapshot => _configurationSnapshot;

  @override
  SdkStatusStore get statusStore => _statusStore;

  @override
  RuntimeInAppContentBlockController? get inAppContentBlocksController =>
      _plugin.inAppContentBlocksController;

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
    if (request.mode == IntegrationMode.stream &&
        request.jwtKeyId.isNotEmpty &&
        request.jwtSecret.isNotEmpty) {
      LocalJwtTokenGenerator.instance.configure(
        secret: request.jwtSecret,
        kid: request.jwtKeyId,
      );
    }

    SdkSetupState.reset();
    SdkSetupState.setStreamConfig(request.mode);
    CustomerIdentifier? customerIdentifier;
    if (request.customerId.isNotEmpty) {
      final customerIds = {'registered': request.customerId};
      SdkSetupState.setCustomerIds(customerIds);
      SdkSetupState.isCustomerIdentified = true;
      if (request.mode == IntegrationMode.stream &&
          LocalJwtTokenGenerator.instance.isConfigured) {
        customerIdentifier = CustomerIdentity(
          customerIds: customerIds,
          sdkAuthToken:
              LocalJwtTokenGenerator.instance.generateToken(customerIds),
        );
      } else {
        customerIdentifier = CustomerIdentity(customerIds: customerIds);
      }
    }

    final configuration = _buildConfiguration(request);
    await _saveCustomerTokenIds(SdkSetupState.customerIds);

    if (request.mode == IntegrationMode.stream &&
        LocalJwtTokenGenerator.instance.isConfigured) {
      StreamAuthListener.start();
    }

    try {
      await _plugin.setAppInboxProvider(buildExampleAppInboxStyle());
      if (!await _isIosSimulator()) {
        await _plugin.checkPushSetup();
      }
      // iOS workaround: plugin configure(with:authContext:) skips push
      // self-check. Configure anonymously first (self-check path), then identify.
      if (Platform.isIOS && customerIdentifier != null) {
        await _plugin.configure(configuration);
        await _plugin.identifyCustomer(customerIdentifier);
      } else {
        await _plugin.configure(
          configuration,
          customerIdentifier: customerIdentifier,
        );
      }
      await _plugin.setFlushMode(FlushMode.immediate);
      _configured = true;
      await _startListeners();
      _configurationSnapshot =
          SdkConfigurationSnapshot.fromExponeaConfiguration(configuration);
      _statusStore.set(
        customerIdentifier != null
            ? SdkLifecycleState.identified
            : SdkLifecycleState.anonymous,
      );
      appendLog('SDK configured (${request.mode.name})');
    } on PlatformException catch (error) {
      StreamAuthListener.stop();
      _statusStore.set(SdkLifecycleState.notInitialized);
      appendLog('Configure failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> clearLocalCustomerData() async {
    try {
      await _plugin.clearLocalCustomerData();
    } on PlatformException catch (error) {
      // iOS SDK requires configuration for this call. When invoked pre-config
      // (first launch or after stopIntegration), the native call fails but
      // local Dart state should still be reset.
      appendLog('clearLocalCustomerData native call skipped: ${error.message}');
    }
    SdkSetupState.reset();
    await _saveCustomerTokenIds(const {});
    _statusStore.set(
      _configured
          ? SdkLifecycleState.anonymous
          : SdkLifecycleState.notInitialized,
    );
    appendLog('Local customer data cleared');
  }

  @override
  Future<void> anonymize() async {
    try {
      await _plugin.anonymize();
      SdkSetupState.reset();
      await _saveCustomerTokenIds(const {});
      _statusStore.set(SdkLifecycleState.anonymous);
      appendLog('Customer anonymized');
    } on PlatformException catch (error) {
      appendLog('anonymize failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> stopIntegration() async {
    StreamAuthListener.stop();
    // Not awaited: stop can be triggered from an in-app button whose native callback is still
    // running, and awaiting the EventChannel cancel there would block the stop itself.
    unawaited(_stopListeners());
    try {
      await _plugin.stopIntegration();
      appendLog('SDK integration stopped');
    } on PlatformException catch (error) {
      // Native can report "not configured" when a previous (asynchronous)
      // stopIntegration already de-integrated the SDK — e.g. rapid
      // start/reset taps. Treat it as already stopped so reset never strands
      // the app in an unrecoverable state.
      appendLog('Stop integration skipped: ${error.message}');
    } finally {
      SdkSetupState.reset();
      _configured = false;
      _configurationSnapshot = null;
      _statusStore.set(SdkLifecycleState.notInitialized);
    }
  }

  /// Demonstrates the plugin's event APIs by logging every event, like the Android example app.
  /// In-app actions are observed only, so the SDK keeps its default button and close behaviour.
  Future<void> _startListeners() async {
    await _stopListeners();
    for (final category in segmentationListenerCategories) {
      try {
        final stream = await _plugin.segmentationDataStream(category);
        _listenerSubscriptions.add(
          stream.listen((segments) {
            appendLog('Segmentation: new data for $category: $segments');
          }),
        );
      } catch (error) {
        appendLog('Segmentation listener for $category failed: $error');
      }
    }
    _listen<InAppMessageAction>(
      'InAppMessage',
      () => _plugin.inAppMessageActionStream(),
      (action) {
        final details = [
          action.message?.name,
          action.button?.text,
          action.button?.url,
          action.errorMessage,
        ].whereType<String>().where((value) => value.isNotEmpty).join(', ');
        appendLog('InAppMessage: ${action.type.name} $details'.trimRight());
      },
    );
    _listen<ReceivedPush>(
      'Push',
      () => _plugin.receivedPushStream,
      (push) => appendLog('Push: received ${push.data}'),
    );
    _listen<OpenedPush>(
      'Push',
      () => _plugin.openedPushStream,
      (push) => appendLog(
        'Push: opened ${push.action.name}${push.url != null ? ' ${push.url}' : ''}',
      ),
    );
  }

  /// Persists customer IDs for the native customer token provider (Advanced auth key).
  Future<void> _saveCustomerTokenIds(Map<String, String> customerIds) async {
    try {
      await CustomerTokenIds.save(customerIds);
    } catch (error) {
      appendLog('Saving customer IDs for customer token failed: $error');
    }
  }

  void _listen<T>(
    String name,
    Stream<T> Function() stream,
    void Function(T event) onEvent,
  ) {
    try {
      _listenerSubscriptions.add(
        stream().listen(
          onEvent,
          onError: (Object error) => appendLog('$name listener error: $error'),
        ),
      );
    } catch (error) {
      appendLog('$name listener failed: $error');
    }
  }

  Future<void> _stopListeners() async {
    final subscriptions = List.of(_listenerSubscriptions);
    _listenerSubscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  }

  @override
  void resetShellState() {
    clearLogs();
  }

  @override
  Future<String> fetchConsents() async {
    try {
      final consents = await _plugin.fetchConsents();
      appendLog('fetchConsents (${consents.length} items)');
      return consents.toString();
    } on PlatformException catch (error) {
      appendLog('fetchConsents failed: ${error.message}');
      return _formatPlatformError(error);
    }
  }

  @override
  Future<String> fetchRecommendation({required String recommendationId}) async {
    try {
      final recommendations = await _plugin.fetchRecommendations(
        RecommendationOptions(
          id: recommendationId,
          fillWithRandom: true,
        ),
      );
      appendLog('fetchRecommendation($recommendationId)');
      return recommendations.toString();
    } on PlatformException catch (error) {
      appendLog('fetchRecommendation failed: ${error.message}');
      return _formatPlatformError(error);
    }
  }

  @override
  Future<String> fetchSegments({String exposingCategory = 'discovery'}) async {
    // iOS ManualSegmentationManager may never invoke the native callback when
    // force=false (cache path) or on some fetch completions, so iOS forces a
    // fresh fetch.
    final forceFetch = defaultTargetPlatform == TargetPlatform.iOS;
    try {
      final segments = await _plugin
          .getSegments(exposingCategory, force: forceFetch)
          .timeout(_segmentsFetchTimeout);
      appendLog('fetchSegments($exposingCategory, force: $forceFetch)');
      return 'Segments ($exposingCategory):\n$segments';
    } on TimeoutException {
      const message =
          'Segments fetch timed out after 15 seconds (native callback may not have completed).';
      appendLog('fetchSegments timed out');
      return 'Message: $message\nJSON: null';
    } on PlatformException catch (error) {
      appendLog('fetchSegments failed: ${error.message}');
      return _formatPlatformError(error);
    }
  }

  String _formatPlatformError(PlatformException error) {
    final details = error.details;
    if (details is Map) {
      final message = details['message'] ?? error.message ?? error.toString();
      final jsonBody = details['jsonBody'];
      return 'Message: $message\nJSON: $jsonBody';
    }
    return 'Message: ${error.message ?? error.toString()}\nJSON: null';
  }

  @override
  Future<String> getCustomerCookie() async {
    try {
      final cookie = await _plugin.getCustomerCookie();
      appendLog('getCustomerCookie');
      return cookie;
    } on PlatformException catch (error) {
      appendLog('getCustomerCookie failed: ${error.message}');
      return '';
    }
  }

  @override
  Future<void> identifyCustomer({
    required Map<String, String> customerIds,
    Map<String, dynamic> properties = const {},
    bool withAuthToken = false,
  }) async {
    try {
      String? token;
      if (withAuthToken) {
        if (!LocalJwtTokenGenerator.instance.isConfigured) {
          appendLog('identifyCustomer: JWT not configured');
          throw StateError('JWT Key ID and Secret must be provided during configuration.');
        }
        token = LocalJwtTokenGenerator.instance.generateToken(customerIds);
        if (token == null) {
          appendLog('identifyCustomer: token generation failed');
          throw StateError('Token generation failed');
        }
      }

      if (SdkSetupState.isStreamConfig) {
        await _plugin.identifyCustomer(
          CustomerIdentity(
            customerIds: customerIds,
            sdkAuthToken: token,
          ),
          properties: properties,
        );
      } else {
        await _plugin.identifyCustomer(
          Customer(ids: customerIds),
          properties: properties,
        );
      }
      SdkSetupState.setCustomerIds(customerIds);
      SdkSetupState.isCustomerIdentified = true;
      await _saveCustomerTokenIds(customerIds);
      _statusStore.set(SdkLifecycleState.identified);
      appendLog('Customer identified');
    } on PlatformException catch (error) {
      appendLog('identifyCustomer failed: ${error.message}');
      rethrow;
    }
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
    final customerIds = SdkSetupState.customerIds;
    final token = LocalJwtTokenGenerator.instance.generateToken(customerIds);
    if (token == null) {
      appendLog('Set auth token: token generation failed');
      return 'Token generation failed';
    }
    try {
      await _plugin.setSdkAuthToken(token);
      appendLog('Auth token set');
      return 'Auth token set';
    } on PlatformException catch (error) {
      appendLog('setSdkAuthToken failed: ${error.message}');
      return 'Token generation failed';
    }
  }

  @override
  Future<void> trackPageView({required String screenName}) async {
    try {
      await _plugin.trackEvent(
        Event(name: 'page_view', properties: {'screen_name': screenName}),
      );
      appendLog('Page view tracked: $screenName');
    } on PlatformException catch (error) {
      appendLog('trackPageView failed: ${error.message}');
    }
  }

  @override
  Future<void> trackCustomEvent({
    required String eventType,
    required Map<String, dynamic> properties,
  }) async {
    try {
      await _plugin.trackEvent(Event(name: eventType, properties: properties));
      appendLog('Custom event tracked: $eventType');
    } on PlatformException catch (error) {
      appendLog('trackEvent failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> trackDemoPayment() async {
    try {
      await _plugin.trackPaymentEvent(
        const PurchasedItem(
          value: 99,
          currency: 'USD',
          paymentSystem: 'System',
          productId: 'demo_item',
          productTitle: 'Demo Item',
        ),
      );
      appendLog('Payment tracked: 99 USD demo_item');
    } on PlatformException catch (error) {
      appendLog('trackPaymentEvent failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<bool> requestPushAuthorization() async {
    try {
      final granted = await _plugin.requestPushAuthorization();
      appendLog('Push permission granted: $granted');
      return granted;
    } on PlatformException catch (error) {
      appendLog('requestPushAuthorization failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> trackDemoFcmToken() async {
    final fakeToken = 'demo-fcm-token-${DateTime.now().millisecondsSinceEpoch}';
    try {
      await _plugin.trackPushToken(fakeToken);
      appendLog('FCM token tracked (demo value): $fakeToken');
    } on PlatformException catch (error) {
      appendLog('trackPushToken failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> trackDemoPushDelivered() async {
    try {
      await _plugin.trackDeliveredPush({'campaign_id': 'demo'});
      appendLog('Delivered push tracked (campaign_id=demo)');
    } on PlatformException catch (error) {
      appendLog('trackDeliveredPush failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> trackDemoPushClicked() async {
    try {
      await _plugin.trackClickedPush({'campaign_id': 'demo'});
      appendLog('Clicked push tracked (campaign_id=demo)');
    } on PlatformException catch (error) {
      appendLog('trackClickedPush failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<FlushMode> getFlushMode() async {
    try {
      final mode = await _plugin.getFlushMode();
      appendLog('getFlushMode');
      return mode;
    } on PlatformException catch (error) {
      appendLog('getFlushMode failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> setFlushMode(FlushMode mode) async {
    try {
      await _plugin.setFlushMode(mode);
      appendLog('setFlushMode($mode)');
    } on PlatformException catch (error) {
      appendLog('setFlushMode failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<Duration> getFlushPeriod() async {
    try {
      final period = await _plugin.getFlushPeriod();
      appendLog('getFlushPeriod');
      return period;
    } on PlatformException catch (error) {
      appendLog('getFlushPeriod failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> setFlushPeriod(Duration period) async {
    try {
      await _plugin.setFlushPeriod(period);
      appendLog('setFlushPeriod($period)');
    } on PlatformException catch (error) {
      appendLog('setFlushPeriod failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> flushData() async {
    try {
      await _plugin.flushData();
      appendLog('flushData completed — queued SDK data sent to backend');
    } on PlatformException catch (error) {
      appendLog('flushData failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<LogLevel> getLogLevel() async {
    try {
      final level = await _plugin.getLogLevel();
      appendLog('getLogLevel');
      return level;
    } on PlatformException catch (error) {
      appendLog('getLogLevel failed: ${error.message}');
      rethrow;
    }
  }

  @override
  Future<void> setLogLevel(LogLevel level) async {
    if (!_configured) {
      // iOS SDK requires configuration before setLogLevel. Silently skip
      // rather than crashing — log level will be applied after configure().
      return;
    }
    try {
      await _plugin.setLogLevel(level);
      appendLog('setLogLevel($level)');
    } on PlatformException catch (error) {
      appendLog('setLogLevel failed: ${error.message}');
      rethrow;
    }
  }

  ExponeaConfiguration _buildConfiguration(ConfigureRequest request) {
    const defaultProperties = {'sdk_demo_app': 'flutter-2026'};
    final android = AndroidExponeaConfiguration(
      automaticPushNotifications: true,
      httpLoggingLevel: HttpLoggingLevel.body,
    );
    const ios = IOSExponeaConfiguration(
      appGroup: 'group.com.exponea.sdk.example',
    );
    final applicationId =
        request.applicationId.isEmpty ? null : request.applicationId;

    if (request.mode == IntegrationMode.stream) {
      return ExponeaConfiguration(
        integrationConfig: StreamIntegrationConfig(
          streamId: request.streamId,
          baseUrl: request.baseUrl,
        ),
        defaultProperties: defaultProperties,
        pushTokenTrackingFrequency: TokenFrequency.onTokenChange,
        android: android,
        ios: ios,
        applicationId: applicationId,
      );
    }

    return ExponeaConfiguration(
      integrationConfig: ProjectIntegrationConfig(
        projectToken: request.projectToken,
        authorizationToken: request.authorizationToken,
        baseUrl: request.baseUrl,
      ),
      advancedAuthEnabled: request.advancedAuthToken.isNotEmpty,
      defaultProperties: defaultProperties,
      pushTokenTrackingFrequency: TokenFrequency.onTokenChange,
      android: android,
      ios: ios,
      applicationId: applicationId,
    );
  }
}
