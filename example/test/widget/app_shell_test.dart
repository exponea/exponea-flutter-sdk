import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:exponea_example/services/plugin_exponea_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

Future<void> _emitDeeplink(WidgetTester tester, String uri) async {
  const channel = MethodChannel('exponea_example/deeplinks');
  final messenger = tester.binding.defaultBinaryMessenger;
  await messenger.handlePlatformMessage(
    channel.name,
    const StandardMethodCodec().encodeMethodCall(
      MethodCall('linkOpened', uri),
    ),
    (_) {},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'integration_mode': 'project',
      'project_token': 'proj-token',
      'auth_token': 'auth-token',
      'base_url': 'https://api.example.com',
    });
  });
  testWidgets('reset confirms before stopping, then returns to auth', (tester) async {
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

    expect(service.isConfigured, isTrue);
    expect(find.text('Result will appear here.'), findsOneWidget);

    await tester.tap(find.bySemanticsIdentifier('btn_reset_state'));
    await tester.pumpAndSettle();

    // Confirmation dialog only — SDK is still integrated.
    expect(service.isConfigured, isTrue);
    expect(find.bySemanticsIdentifier('btn_reset_back_to_auth'), findsOneWidget);

    await tester.tap(find.bySemanticsIdentifier('btn_reset_back_to_auth'));
    await tester.pumpAndSettle();

    expect(service.isConfigured, isFalse);
    expect(find.text('SDK Configuration'), findsOneWidget);
  });

  testWidgets('reset cancel keeps the SDK integrated and semafor unchanged', (tester) async {
    final handle = tester.ensureSemantics();
    final service = FakeExponeaService();
    await service.configure(
      const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.example.com',
        projectToken: 'proj-token',
        authorizationToken: 'auth-token',
        customerId: 'user-1',
      ),
    );
    await pumpExampleApp(tester, service: service, startOnShell: true);

    String? statusValue() => tester
        .getSemantics(find.bySemanticsIdentifier('status_sdk_indicator'))
        .value;
    expect(statusValue(), 'identified');

    await tester.tap(find.bySemanticsIdentifier('btn_reset_state'));
    await tester.pumpAndSettle();
    expect(service.isConfigured, isTrue);

    await tester.tap(find.bySemanticsIdentifier('btn_reset_cancel'));
    await tester.pumpAndSettle();

    expect(service.isConfigured, isTrue);
    expect(statusValue(), 'identified');
    expect(find.text('Result will appear here.'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('reset stop and continue stops SDK but stays on shell', (tester) async {
    final handle = tester.ensureSemantics();
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

    // SDK must be stopped.
    expect(service.isConfigured, isFalse,
        reason: 'stopIntegration() must have been called');
    // User must remain on the shell.
    expect(find.text('SDK Configuration'), findsNothing,
        reason: 'User must stay on the shell, not navigate to auth');
    // Semafor should be red.
    expect(
      tester.getSemantics(find.bySemanticsIdentifier('status_sdk_indicator')).value,
      'notInitialized',
      reason: 'Semafor must be red after stop and continue',
    );
    handle.dispose();
  });

  testWidgets('reset recovers to auth even when stopIntegration fails', (tester) async {
    final service = FakeExponeaService();
    await service.configure(
      const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.example.com',
        projectToken: 'proj-token',
        authorizationToken: 'auth-token',
      ),
    );
    service.stopIntegrationError = PlatformException(
      code: 'NativeError',
      message: 'Exponea SDK is not configured. Call Exponea.configure() '
          'before calling functions of the SDK',
    );

    await pumpExampleApp(tester, service: service, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_reset_state'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_reset_back_to_auth'), findsOneWidget);

    await tester.tap(find.bySemanticsIdentifier('btn_reset_back_to_auth'));
    await tester.pumpAndSettle();

    expect(find.text('SDK Configuration'), findsOneWidget);
    expect(service.isConfigured, isFalse);
  });

  testWidgets('unvisited tab screen not in widget tree', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    // Content Blocks tab has not been visited yet — its screen must not exist in tree.
    expect(
      find.text('Show carousels', skipOffstage: false),
      findsNothing,
      reason: 'ContentBlocksScreen should not be built before first visit',
    );
  });

  testWidgets('activating btn_nav_anonymize shows anonymize controls', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_anonymize'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_anonymize'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_stop_integration'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('activating btn_nav_fetching shows fetch controls', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_nav_fetching'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_fetch_consents'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('stopAndContinue deeplink stays on shell de-integrated', (
    tester,
  ) async {
    final service = FakeExponeaService();
    await service.configure(
      const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.example.com',
        projectToken: 'tok',
        authorizationToken: 'auth',
      ),
    );
    await pumpExampleApp(tester, service: service, startOnShell: true);

    await _emitDeeplink(tester, 'exponea://stopAndContinue');
    await tester.pumpAndSettle();

    expect(service.isConfigured, isFalse);
    expect(find.bySemanticsIdentifier('btn_nav_fetching'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_auth_start'), findsNothing);
    expect(
      tester
          .getSemantics(find.bySemanticsIdentifier('status_sdk_indicator'))
          .value,
      'notInitialized',
    );
  });

  testWidgets('stopAndRestart deeplink returns to auth', (tester) async {
    final service = FakeExponeaService();
    await service.configure(
      const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.example.com',
        projectToken: 'tok',
        authorizationToken: 'auth',
      ),
    );
    await pumpExampleApp(tester, service: service, startOnShell: true);

    await _emitDeeplink(tester, 'exponea://stopAndRestart');
    await tester.pumpAndSettle();

    expect(service.isConfigured, isFalse);
    expect(find.bySemanticsIdentifier('btn_auth_start'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_nav_fetching'), findsNothing);
  });

  testWidgets('visited tab screen stays mounted offstage after switching away',
      (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    // First visit — screen is built and visible.
    await tester.tap(find.bySemanticsIdentifier('btn_nav_content_blocks'));
    await tester.pumpAndSettle();
    expect(find.text('Show carousels'), findsOneWidget);

    // Switch to Tracking tab.
    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    // Content Blocks screen must still be mounted (offstage) — not torn down.
    expect(
      find.text('Show carousels', skipOffstage: false),
      findsOneWidget,
      reason: 'ContentBlocksScreen must stay mounted after switching away',
    );
  });

  testWidgets('switching back to visited content blocks tab shows screen immediately',
      (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    // Visit Content Blocks, then switch away, then switch back.
    await tester.tap(find.bySemanticsIdentifier('btn_nav_content_blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_nav_content_blocks'));
    await tester.pumpAndSettle();

    // Screen must be visible (on-stage) without needing to re-initialise.
    expect(
      find.text('Show carousels'),
      findsOneWidget,
      reason: 'ContentBlocksScreen must be back on-stage after re-visiting',
    );
  });

  testWidgets('shell fires page_view for initial Fetching tab', (tester) async {
    final service = FakeExponeaService();
    await pumpExampleApp(tester, service: service, startOnShell: true);

    expect(
      service.logs.any((line) => line.contains('trackPageView(Fetching)')),
      isTrue,
      reason: 'Expected page_view logged for initial Fetching tab',
    );
  });

  testWidgets('shell fires page_view on tab switch', (tester) async {
    final service = FakeExponeaService();
    await pumpExampleApp(tester, service: service, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    expect(
      service.logs.any((line) => line.contains('trackPageView(Tracking)')),
      isTrue,
      reason: 'Expected page_view logged after navigating to Tracking tab',
    );
  });

  testWidgets('open logs shows bottom sheet', (tester) async {
    await pumpExampleApp(
      tester,
      service: PluginExponeaService(),
      startOnShell: true,
    );

    await tester.tap(find.bySemanticsIdentifier('btn_open_logs'));
    await tester.pumpAndSettle();

    expect(find.text('SDK Logs'), findsOneWidget);
    expect(
      find.text('No logs yet. Trigger an SDK action to populate.'),
      findsOneWidget,
    );
  });

  testWidgets('auth screen shows inline error for invalid API URL', (tester) async {
    await pumpExampleApp(tester, startOnShell: false);
    expect(find.text('SDK Configuration'), findsOneWidget);

    // Type an invalid URL in the API URL field
    final apiUrlField = find.ancestor(
      of: find.text('API URL'),
      matching: find.byType(TextField),
    );
    await tester.enterText(apiUrlField, 'not-a-valid-url');
    await tester.pump();

    expect(
      find.text('Must be a valid http:// or https:// URL'),
      findsOneWidget,
    );
  });

  testWidgets('auth screen hides inline error for valid API URL', (tester) async {
    await pumpExampleApp(tester, startOnShell: false);

    final apiUrlField = find.ancestor(
      of: find.text('API URL'),
      matching: find.byType(TextField),
    );
    await tester.enterText(apiUrlField, 'https://api.example.com');
    await tester.pump();

    expect(
      find.text('Must be a valid http:// or https:// URL'),
      findsNothing,
    );
  });

  testWidgets('auth start configures fake service and opens shell', (tester) async {
    final service = FakeExponeaService();
    await pumpExampleApp(tester, service: service, startOnShell: false);

    expect(find.text('SDK Configuration'), findsOneWidget);

    final startButton = find.bySemanticsIdentifier('btn_auth_start');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(service.isConfigured, isTrue);
    expect(find.text('Result will appear here.'), findsOneWidget);
  });

  group('SDK status indicator', () {
    String? statusValue(WidgetTester tester) => tester
        .getSemantics(find.bySemanticsIdentifier('status_sdk_indicator'))
        .value;

    testWidgets('anonymous after configure without identity', (tester) async {
      final handle = tester.ensureSemantics();
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

      expect(statusValue(tester), 'anonymous');
      handle.dispose();
    });

    testWidgets('green/identified after identify, yellow after anonymize, '
        'red after stop', (tester) async {
      final handle = tester.ensureSemantics();
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
      expect(statusValue(tester), 'anonymous');

      await service.identifyCustomer(customerIds: {'registered': 'user-1'});
      await tester.pump();
      expect(statusValue(tester), 'identified');

      await service.anonymize();
      await tester.pump();
      expect(statusValue(tester), 'anonymous');

      await service.stopIntegration();
      await tester.pump();
      expect(statusValue(tester), 'notInitialized');

      handle.dispose();
    });
  });
}
