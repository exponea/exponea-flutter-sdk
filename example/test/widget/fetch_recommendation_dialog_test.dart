import 'package:exponea_example/features/fetching/recommendation_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'recommendation_id': 'saved-rec-id',
    });
  });

  testWidgets('fetch recommendation dialog prefills saved id', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_fetch_recommendations'));
    await tester.pumpAndSettle();

    expect(find.text('saved-rec-id'), findsOneWidget);
  });

  testWidgets('submitting recommendation id persists value', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_fetch_recommendations'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.bySemanticsIdentifier('fld_recommendation_id'),
      'new-rec-id',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_recommendation_dialog_fetch'));
    await tester.pumpAndSettle();

    expect(await RecommendationPreferences.loadId(), 'new-rec-id');
  });
}
