import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Last known customer IDs for JWT generation in the example app.
///
/// Also persists IDs to SharedPreferences so native [CustomerTokenStorage]
/// can read them for advanced authorization (App Inbox).
class SdkSetupState {
  SdkSetupState._();

  static const _spKeyCustomerIds = 'customer_ids';

  static Map<String, String> _customerIds = {};

  static Map<String, String> get customerIds =>
      Map.unmodifiable(_customerIds);

  static Future<void> setCustomerIds(Map<String, String> ids) async {
    _customerIds = Map<String, String>.from(ids);
    final sp = await SharedPreferences.getInstance();
    if (ids.isEmpty) {
      await sp.remove(_spKeyCustomerIds);
      return;
    }

    await sp.setString(_spKeyCustomerIds, json.encode(ids));
  }

  static Future<void> reset() async {
    _customerIds = {};
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_spKeyCustomerIds);
  }
}
