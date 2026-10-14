import 'package:exponea_example/features/fetching/recommendation_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load returns empty string when unset', () async {
    expect(await RecommendationPreferences.loadId(), '');
  });

  test('save and load round-trip', () async {
    await RecommendationPreferences.saveId('rec-demo');
    expect(await RecommendationPreferences.loadId(), 'rec-demo');
  });
}
