import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Customer IDs for the native customer token providers (`ExampleAuthProvider` on Android
/// and iOS). They read `flutter.customer_ids` next to the persisted `base_url`,
/// `project_token` and `advanced_auth_token` auth form fields, as in the legacy example.
abstract final class CustomerTokenIds {
  static const key = 'customer_ids';

  static Future<void> save(Map<String, String> customerIds) async {
    final preferences = await SharedPreferences.getInstance();
    if (customerIds.isEmpty) {
      await preferences.remove(key);
    } else {
      await preferences.setString(key, jsonEncode(customerIds));
    }
  }

  static Future<void> clear() => save(const {});
}
