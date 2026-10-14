import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:exponea_example/util/local_jwt_generator.dart';
import 'package:exponea_example/util/sdk_setup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

const _projectRequest = ConfigureRequest(
  mode: IntegrationMode.project,
  baseUrl: 'https://api.example.com',
  projectToken: 'proj-token',
  authorizationToken: 'auth-token',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (message) async {
      if (message.method == 'Clipboard.setData') {
        return null;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
  testWidgets('identify customer opens dialog', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_identify_customer'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Identify Customer'),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsIdentifier('btn_identify'), findsOneWidget);
    expect(find.bySemanticsIdentifier('lbl_registered_id'), findsOneWidget);
    expect(find.bySemanticsIdentifier('fld_registered_id'), findsNothing);
    expect(find.bySemanticsIdentifier('btn_identify_cancel'), findsOneWidget);
  });

  testWidgets('identified customer shows read-only registered label', (
    tester,
  ) async {
    final service = FakeExponeaService();
    await pumpExampleApp(tester, startOnShell: true, service: service);
    await service
        .identifyCustomer(customerIds: {'registered': 'known@test.com'});

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_identify_customer'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('fld_registered_id'), findsNothing);
    expect(find.bySemanticsIdentifier('lbl_registered_id'), findsOneWidget);
    expect(find.text('registered: known@test.com'), findsOneWidget);
  });

  testWidgets('identify cancel dismisses dialog', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_identify_customer'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_identify_cancel'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_identify'), findsNothing);
  });

  testWidgets('track custom event opens dialog', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_track_custom_event'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Track Custom Event'),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsIdentifier('btn_track_event'), findsOneWidget);
  });

  testWidgets('in-app preset picker exposes labels as plain text', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_track_custom_event'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('sel_inapp_preset'));
    await tester.pumpAndSettle();

    expect(find.text('Control Group'), findsOneWidget);
    await tester.tap(find.text('Control Group'));
    await tester.pumpAndSettle();

    expect(find.text('Control Group'), findsOneWidget);
    expect(find.textContaining('test_msg_control_group'), findsOneWidget);
  });

  testWidgets('identify commits pending attr fields without Add', (tester) async {
    final service = FakeExponeaService();
    await pumpExampleApp(tester, startOnShell: true, service: service);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_identify_customer'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.bySemanticsIdentifier('fld_identify_attr_value'),
      'e2e@example.com',
    );
    await tester.tap(find.bySemanticsIdentifier('btn_identify'));
    await tester.pumpAndSettle();

    expect(find.text('Customer identified successfully'), findsOneWidget);
    expect(find.bySemanticsIdentifier('OK'), findsOneWidget);
    expect(
      service.logs.any((line) => line.contains('identifyCustomer')),
      isTrue,
    );
    expect(SdkSetupState.registeredId, 'e2e@example.com');

    await tester.tap(find.bySemanticsIdentifier('OK'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('btn_identify'), findsNothing);
  });

  testWidgets('identify attr value semantics mirrors controller text', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_identify_customer'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.bySemanticsIdentifier('fld_identify_attr_value'),
      'test@example.com',
    );
    await tester.pump();

    expect(
      tester
          .getSemantics(find.bySemanticsIdentifier('fld_identify_attr_value'))
          .value,
      'test@example.com',
    );
    handle.dispose();
  });

  testWidgets('identify success shows suite AlertDialog then closes', (
    tester,
  ) async {
    final service = FakeExponeaService();
    await pumpExampleApp(tester, startOnShell: true, service: service);
    await service.identifyCustomer(customerIds: {'registered': 'known@test.com'});

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_identify_customer'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_identify'));
    await tester.pumpAndSettle();

    expect(find.text('Customer identified successfully'), findsOneWidget);
    await tester.tap(find.bySemanticsIdentifier('OK'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('btn_identify'), findsNothing);
  });

  testWidgets('identify failure keeps dialog open after OK', (tester) async {
    final service = _ThrowingIdentifyFake();
    await pumpExampleApp(tester, startOnShell: true, service: service);
    await service.identifyCustomer(customerIds: {'registered': 'known@test.com'});
    // Reset so next dialog identify uses throwing override — Fake already identified.
    // The throwing fake fails on subsequent identifyCustomer calls from UI.
    service.failNextIdentify = true;

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_identify_customer'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_identify'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to identify customer'), findsOneWidget);
    await tester.tap(find.bySemanticsIdentifier('OK'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('btn_identify'), findsOneWidget);
  });

  testWidgets('identify with auth token visible in stream mode',
      (tester) async {
    LocalJwtTokenGenerator.instance.configure(
      secret: 'test-secret',
      kid: 'test-kid',
    );
    final service = FakeExponeaService();
    await pumpExampleApp(
      tester,
      service: service,
      startOnShell: true,
      streamMode: true,
    );

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_identify_customer'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_identify_auth'), findsOneWidget);
  });

  testWidgets('track page view button is visible and fires page_view',
      (tester) async {
    final service = FakeExponeaService();
    await pumpExampleApp(tester, startOnShell: true, service: service);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('btn_track_page_view'),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsIdentifier('btn_track_page_view'));
    await tester.pumpAndSettle();

    expect(
      service.logs.any((line) => line.contains('trackPageView(Tracking)')),
      isTrue,
      reason: 'Expected page_view logged after tapping Track Page View',
    );
  });

  testWidgets('track payment appends log', (tester) async {
    final service = FakeExponeaService();
    await pumpExampleApp(tester, startOnShell: true, service: service);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_track_payment'));
    await tester.pumpAndSettle();

    expect(
      service.logs.any((line) => line.contains('trackPaymentEvent')),
      isTrue,
    );
  });

  testWidgets(
      'tracking screen uses yellow filled style only for primary actions',
      (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    for (final id in ['btn_identify_customer', 'btn_request_push']) {
      expect(
        find.descendant(
          of: find.bySemanticsIdentifier(id),
          matching: find.byType(FilledButton),
        ),
        findsOneWidget,
      );
    }

    for (final id in [
      'btn_set_auth_token',
      'btn_track_custom_event',
      'btn_track_payment',
      'btn_track_page_view',
      'btn_track_fcm_token',
      'btn_track_push_delivered',
      'btn_track_push_clicked',
    ]) {
      expect(
        find.descendant(
          of: find.bySemanticsIdentifier(id),
          matching: find.byType(OutlinedButton),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('push delivered and clicked buttons share one row',
      (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    final delivered = find.bySemanticsIdentifier('btn_track_push_delivered');
    final clicked = find.bySemanticsIdentifier('btn_track_push_clicked');

    expect(
      find.ancestor(of: delivered, matching: find.byType(Row)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: clicked, matching: find.byType(Row)),
      findsOneWidget,
    );
  });

  Future<void> _openTracking(WidgetTester tester) async {
    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();
  }

  Finder _copyCookieButton() {
    return find.descendant(
      of: find.bySemanticsIdentifier('btn_copy_cookie_id'),
      matching: find.byType(IconButton),
    );
  }

  testWidgets('copy cookie button disabled when cookie not initialized',
      (tester) async {
    await pumpExampleApp(tester, startOnShell: true);
    await _openTracking(tester);

    expect(find.bySemanticsIdentifier('btn_copy_cookie_id'), findsOneWidget);
    expect(tester.widget<IconButton>(_copyCookieButton()).onPressed, isNull);
  });

  testWidgets('copy cookie button shows SnackBar with cookie value',
      (tester) async {
    final service = FakeExponeaService();
    await service.configure(_projectRequest);
    await pumpExampleApp(tester, service: service, startOnShell: true);
    await _openTracking(tester);

    expect(find.text('fake-customer-cookie'), findsOneWidget);
    expect(tester.widget<IconButton>(_copyCookieButton()).onPressed, isNotNull);

    await tester.tap(_copyCookieButton());
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('Cookie ID copied to clipboard'),
      ),
      findsOneWidget,
    );
  });
}

class _ThrowingIdentifyFake extends FakeExponeaService {
  bool failNextIdentify = false;

  @override
  Future<void> identifyCustomer({
    required Map<String, String> customerIds,
    Map<String, dynamic> properties = const {},
    bool withAuthToken = false,
  }) async {
    if (failNextIdentify) {
      throw StateError('simulated identify failure');
    }
    return super.identifyCustomer(
      customerIds: customerIds,
      properties: properties,
      withAuthToken: withAuthToken,
    );
  }
}
