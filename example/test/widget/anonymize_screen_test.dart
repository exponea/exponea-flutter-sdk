import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

const _projectRequest = ConfigureRequest(
  mode: IntegrationMode.project,
  baseUrl: 'https://api.example.com',
  projectToken: 'proj-token',
  authorizationToken: 'auth-token',
);

void main() {
  testWidgets('anonymize tab shows primary buttons', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_anonymize'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_anonymize'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_stop_integration'), findsOneWidget);
  });

  testWidgets('anonymize shows result dialog with ok button', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_anonymize'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_anonymize'));
    await tester.pumpAndSettle();

    expect(find.text('Customer anonymized'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_anonymized_ok'), findsOneWidget);
  });

  testWidgets('stop integration shows confirmation dialog without stopping', (tester) async {
    final service = FakeExponeaService();
    await service.configure(_projectRequest);
    await pumpExampleApp(tester, service: service, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_anonymize'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_stop_integration'));
    await tester.pumpAndSettle();

    // The dialog is a confirmation: the SDK is NOT stopped yet.
    expect(service.isConfigured, isTrue);
    expect(find.bySemanticsIdentifier('btn_stop_back_to_auth'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_stop_stop_and_continue'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_stop_cancel'), findsOneWidget);
  });

  testWidgets('stop integration cancel keeps the SDK integrated', (tester) async {
    final service = FakeExponeaService();
    await service.configure(_projectRequest);
    await pumpExampleApp(tester, service: service, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_anonymize'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_stop_integration'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_stop_cancel'));
    await tester.pumpAndSettle();

    expect(service.isConfigured, isTrue);
    expect(find.bySemanticsIdentifier('btn_stop_integration'), findsOneWidget);
  });

  testWidgets(
      'stop and continue stops SDK but keeps user on shell screen',
      (tester) async {
    final service = FakeExponeaService();
    await service.configure(_projectRequest);
    await pumpExampleApp(tester, service: service, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_anonymize'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_stop_integration'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_stop_stop_and_continue'));
    await tester.pumpAndSettle();

    // SDK must be stopped.
    expect(service.isConfigured, isFalse,
        reason: 'stopIntegration() must have been called');
    // User must remain on the shell (auth screen text must NOT be visible).
    expect(find.text('SDK Configuration'), findsNothing,
        reason: 'User must stay on the shell, not navigate to auth');
    // Stop Integration button still accessible.
    expect(find.bySemanticsIdentifier('btn_stop_integration'), findsOneWidget,
        reason: 'Stop Integration button must still be visible on shell');
  });

  testWidgets('lbl_anonymized_title is present on the anonymized dialog', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_anonymize'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_anonymize'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('lbl_anonymized_title'),
      findsOneWidget,
      reason:
          'Anonymized dialog title must expose lbl_anonymized_title',
    );
  });

  testWidgets('stop integration back to auth stops and navigates', (tester) async {
    final service = FakeExponeaService();
    await service.configure(_projectRequest);
    await pumpExampleApp(tester, service: service, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_anonymize'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_stop_integration'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_stop_back_to_auth'));
    await tester.pumpAndSettle();

    expect(service.isConfigured, isFalse);
    expect(find.text('SDK Configuration'), findsOneWidget);
  });
}
