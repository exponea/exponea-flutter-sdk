import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Future<void> _openConfigurationSheet(WidgetTester tester) async {
  await tester.tap(find.bySemanticsIdentifier('btn_shell_logo'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('logo tap opens Exponea configuration sheet when configured', (
    tester,
  ) async {
    final service = FakeExponeaService();
    await service.configure(
      const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.example.com',
        projectToken: 'proj-token',
        authorizationToken: 'auth-token',
      ),
    );

    await pumpExampleApp(tester, service: service, startOnShell: true);

    await _openConfigurationSheet(tester);

    expect(find.text('Exponea configuration'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_config_close'), findsOneWidget);
  });

  testWidgets('configured sheet shows token frequency and application ID', (
    tester,
  ) async {
    final service = FakeExponeaService();
    await service.configure(
      const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.example.com',
        projectToken: 'proj-token',
        authorizationToken: 'auth-token',
        applicationId: 'my-custom-app',
      ),
    );

    await pumpExampleApp(tester, service: service, startOnShell: true);
    await _openConfigurationSheet(tester);

    expect(find.text('Token track frequency'), findsOneWidget);
    expect(find.text('on token change'), findsOneWidget);
    expect(find.text('Application ID'), findsOneWidget);
    expect(find.text('my-custom-app'), findsOneWidget);
    expect(
      find.bySemanticsIdentifier('lbl_config_token_frequency'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsIdentifier('lbl_config_application_id'),
      findsOneWidget,
    );
  });

  testWidgets('empty application ID resolves to default-application', (
    tester,
  ) async {
    final service = FakeExponeaService();
    await service.configure(
      const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.example.com',
        projectToken: 'proj-token',
        authorizationToken: 'auth-token',
      ),
    );

    await pumpExampleApp(tester, service: service, startOnShell: true);
    await _openConfigurationSheet(tester);

    expect(find.text('default-application'), findsOneWidget);
  });

  testWidgets('stop and continue shows SDK not configured in sheet', (
    tester,
  ) async {
    final service = FakeExponeaService();
    await service.configure(
      const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.example.com',
        projectToken: 'proj-token',
        authorizationToken: 'auth-token',
      ),
    );

    await pumpExampleApp(tester, service: service, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_reset_state'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_reset_stop_and_continue'));
    await tester.pumpAndSettle();

    await _openConfigurationSheet(tester);

    expect(find.text('SDK not configured'), findsOneWidget);
    expect(
      find.bySemanticsIdentifier('lbl_config_not_configured'),
      findsOneWidget,
    );
    expect(find.text('Token track frequency'), findsNothing);
    expect(find.text('Application ID'), findsNothing);
  });
}
