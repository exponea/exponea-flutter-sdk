import 'package:exponea_example/models/integration_mode.dart';

/// Last known SDK setup flags for the example app (identify, JWT, Stream mode).
class SdkSetupState {
  SdkSetupState._();

  static Map<String, String> _customerIds = {};
  static bool isStreamConfig = false;
  static bool isCustomerIdentified = false;

  static Map<String, String> get customerIds => Map.unmodifiable(_customerIds);

  static String get registeredId => _customerIds['registered'] ?? '';

  static void setCustomerIds(Map<String, String> ids) {
    _customerIds = Map<String, String>.from(ids);
  }

  static void setStreamConfig(IntegrationMode mode) {
    isStreamConfig = mode == IntegrationMode.stream;
  }

  static void reset() {
    _customerIds = {};
    isStreamConfig = false;
    isCustomerIdentified = false;
  }
}
