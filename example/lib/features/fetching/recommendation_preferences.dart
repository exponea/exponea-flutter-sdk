import 'package:shared_preferences/shared_preferences.dart';

abstract final class RecommendationPreferences {
  static const _keyRecommendationId = 'recommendation_id';

  static Future<String> loadId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_keyRecommendationId) ?? '';
  }

  static Future<void> saveId(String recommendationId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_keyRecommendationId, recommendationId);
  }
}
