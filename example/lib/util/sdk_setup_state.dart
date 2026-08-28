/// Last known customer IDs for JWT generation in the example app.
class SdkSetupState {
  SdkSetupState._();

  static Map<String, String> _customerIds = {};

  static Map<String, String> get customerIds =>
      Map.unmodifiable(_customerIds);

  static void setCustomerIds(Map<String, String> ids) {
    _customerIds = Map<String, String>.from(ids);
  }

  static void reset() {
    _customerIds = {};
  }
}
