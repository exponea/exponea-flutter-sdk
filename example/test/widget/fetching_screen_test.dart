import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('fetch consents shows result in panel', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    expect(find.text('Result will appear here.'), findsOneWidget);

    await tester.tap(find.bySemanticsIdentifier('btn_fetch_consents'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Consent{category: newsletter'),
      findsOneWidget,
    );
  });

  testWidgets('status_fetch_loading is always present on fetching screen', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: true);

    expect(
      find.bySemanticsIdentifier('status_fetch_loading'),
      findsOneWidget,
      reason: 'LinearProgressIndicator must expose status_fetch_loading',
    );
  });

  testWidgets('lbl_fetch_result is present on fetching screen', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    expect(
      find.bySemanticsIdentifier('lbl_fetch_result'),
      findsOneWidget,
      reason: 'Result SelectableText must expose lbl_fetch_result',
    );
  });

  testWidgets('inbox buttons hide after SDK stop', (tester) async {
    final service = FakeExponeaService();
    await pumpExampleApp(tester, startOnShell: true, service: service);

    expect(find.bySemanticsIdentifier('btn_open_inbox'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_app_inbox_provider'), findsOneWidget);

    await service.stopIntegration();
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_open_inbox'), findsNothing);
    expect(find.bySemanticsIdentifier('btn_app_inbox_provider'), findsNothing);
  });
}
