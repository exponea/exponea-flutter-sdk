import 'package:exponea/src/data/model/configuration.dart';
import 'package:exponea/src/data/model/consent.dart';
import 'package:exponea/src/data/model/event_type.dart';
import 'package:exponea/src/data/model/flush_mode.dart';
import 'package:exponea/src/data/model/log_level.dart';
import 'package:exponea/src/data/model/project.dart';
import 'package:exponea/src/data/model/recommendation.dart';

import '../interface.dart';
import '../platform/platform_interface.dart';

class ExponeaPlugin implements BaseInterface {
  ExponeaPlatform get _platform => ExponeaPlatform.instance;

  @override
  Future<void> anonymize({
    ExponeaProject? exponeaProject,
    Map<EventType, List<ExponeaProject>>? mapping,
  }) =>
      _platform.anonymize(
        exponeaProject: exponeaProject,
        mapping: mapping,
      );

  @override
  Future<void> checkPushSetup() => _platform.checkPushSetup();

  @override
  Future<void> configure(ExponeaConfiguration configuration) =>
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
  Future<void> identifyCustomer({
    required Map<String, String> customerIds,
    required Map<String, dynamic> properties,
  }) =>
      _platform.identifyCustomer(
        customerIds: customerIds,
        properties: properties,
      );

  @override
  Future<bool> isConfigured() => _platform.isConfigured();

  @override
  void removePushOpenedListener() => _platform.removePushOpenedListener();

  @override
  void removePushReceivedListener() => _platform.removePushReceivedListener();

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
  void setPushOpenedListener(OpenedPushListener listener) =>
      _platform.setPushOpenedListener(listener);

  @override
  void setPushReceivedListener(PushReceivedListener listener) =>
      _platform.setPushReceivedListener(listener);

  @override
  Future<void> trackEvent({
    required String eventName,
    required Map<String, dynamic> properties,
    DateTime? timestamp,
  }) =>
      _platform.trackEvent(
        eventName: eventName,
        properties: properties,
        timestamp: timestamp,
      );

  @override
  Future<void> trackSessionEnd(DateTime timestamp) =>
      _platform.trackSessionEnd(timestamp);

  @override
  Future<void> trackSessionStart(DateTime timestamp) =>
      _platform.trackSessionStart(timestamp);
}
