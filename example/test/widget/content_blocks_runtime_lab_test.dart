import 'package:exponea/exponea.dart';
import 'package:exponea_example/features/content_blocks/runtime_controller_lab.dart';
import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Future<void> _openRuntimeLab(WidgetTester tester, FakeExponeaService service) async {
  await pumpExampleApp(tester, service: service, startOnShell: true);
  await tester.tap(find.bySemanticsIdentifier('btn_nav_content_blocks'));
  await tester.pumpAndSettle();
  await tester.tap(find.bySemanticsIdentifier('cb_tab_runtime_lab'));
  await tester.pumpAndSettle();
}

Future<void> _tapLabButton(WidgetTester tester, String id) async {
  final button = find.bySemanticsIdentifier(id);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

String _statusText(WidgetTester tester) {
  final node = tester.getSemantics(find.bySemanticsIdentifier('lbl_cb_runtime_status'));
  return node.label;
}

void main() {
  late FakeExponeaService service;
  late FakeRuntimeInAppContentBlockController controller;

  setUp(() {
    service = FakeExponeaService();
    controller = service.runtimeController;
  });

  testWidgets('Basic tab is the default and keeps the existing placeholders', (tester) async {
    await pumpExampleApp(tester, service: service, startOnShell: true);
    await tester.tap(find.bySemanticsIdentifier('btn_nav_content_blocks'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('cb_tab_classic'), findsOneWidget);
    expect(find.bySemanticsIdentifier('cb_tab_runtime_lab'), findsOneWidget);
    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Runtime Control'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_toggle_carousels'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_cb_runtime_prefetch'), findsNothing);
  });

  testWidgets('Runtime Control tab exposes the RN automation IDs and defaults', (tester) async {
    await _openRuntimeLab(tester, service);

    expect(find.bySemanticsIdentifier('btn_cb_runtime_prefetch'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_cb_runtime_availability'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_cb_runtime_invalidate'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_cb_runtime_logout'), findsOneWidget);
    expect(find.bySemanticsIdentifier('lbl_cb_runtime_status'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_toggle_carousels'), findsNothing);

    expect(find.text('Prefetch'), findsOneWidget);
    expect(find.text('Availability'), findsOneWidget);
    expect(find.text('Prefetch → eager invalidate → availability'), findsOneWidget);
    for (final scenario in [
      'happy path',
      'post-login CMS',
      'logout',
      'availability timeout',
      'anonymize lifecycle probe',
      'identity switch',
      'lazy invalidate',
    ]) {
      expect(find.text(scenario), findsOneWidget, reason: scenario);
    }
    expect(find.text('example_top, ph_x_example_Android'), findsOneWidget);
    expect(find.text('3000'), findsOneWidget);
    expect(find.text('Availability / prefetch snapshot deadline (milliseconds)'), findsOneWidget);
    expect(find.textContaining('user_a, user_b or anonymous'), findsOneWidget);
    expect(_statusText(tester), 'Runtime controller results will appear here.');
  });

  testWidgets('Prefetch logs the snapshot', (tester) async {
    controller.prefetchResult = {
      'example_top': InAppContentBlockAvailability.ready,
      'ph_x_example_Android': InAppContentBlockAvailability.empty,
    };
    await _openRuntimeLab(tester, service);

    await _tapLabButton(tester, 'btn_cb_runtime_prefetch');

    expect(controller.calls, ['prefetch([example_top, ph_x_example_Android], 3000)']);
    final status = _statusText(tester);
    expect(status, contains('BEGIN prefetch ids=example_top, ph_x_example_Android deadline=3000ms'));
    expect(status, contains('prefetch snapshot: {"example_top":"ready","ph_x_example_Android":"empty"}'));
    expect(status, contains('END prefetch'));
  });

  testWidgets('Availability logs one decision per ID', (tester) async {
    controller.availabilityResults = {
      'example_top': const InAppContentBlockAvailabilityResolved(InAppContentBlockAvailability.ready),
      'ph_x_example_Android': const InAppContentBlockAvailabilityTimedOut(),
    };
    await _openRuntimeLab(tester, service);

    await _tapLabButton(tester, 'btn_cb_runtime_availability');

    final status = _statusText(tester);
    expect(status, contains('availability(example_top, 3000ms): {"status":"resolved","availability":"ready"}'));
    expect(status, contains('availability(ph_x_example_Android, 3000ms): {"status":"timedOut"}'));
    expect(status, contains('END availability'));
  });

  testWidgets('Invalidate runs prefetch → eager invalidate → availability', (tester) async {
    await _openRuntimeLab(tester, service);

    await _tapLabButton(tester, 'btn_cb_runtime_invalidate');

    expect(controller.calls, [
      'prefetch([example_top, ph_x_example_Android], null)',
      'invalidate([example_top, ph_x_example_Android], example lab: eager invalidate, eager)',
      'availability(example_top, 3000)',
      'availability(ph_x_example_Android, 3000)',
    ]);
    final status = _statusText(tester);
    expect(status, contains('invalidate(eager): accepted; reload completion is checked separately'));
    expect(status, contains('END eager invalidate'));
  });

  testWidgets('logs FAILED when the controller is not available', (tester) async {
    service.runtimeControllerAvailable = false;
    await _openRuntimeLab(tester, service);

    await _tapLabButton(tester, 'btn_cb_runtime_prefetch');

    expect(_statusText(tester), contains('FAILED prefetch: SDK is not configured'));
    expect(find.text('Controller: not configured'), findsOneWidget);
  });

  testWidgets('warns on invalid input instead of calling the controller', (tester) async {
    await _openRuntimeLab(tester, service);

    await tester.enterText(find.byKey(const ValueKey('cb_runtime_deadline_input')), '-1');
    await _tapLabButton(tester, 'btn_cb_runtime_prefetch');

    expect(controller.calls, isEmpty);
    expect(
      _statusText(tester),
      contains('WARN: Enter at least one placeholder ID and a non-negative deadline in milliseconds.'),
    );
  });

  testWidgets('inputs survive switching tabs; Clear log empties the log', (tester) async {
    await _openRuntimeLab(tester, service);
    await tester.enterText(find.byKey(const ValueKey('cb_runtime_ids_input')), 'example_top_omaticka');
    await tester.enterText(find.byKey(const ValueKey('cb_runtime_deadline_input')), '1500');
    await _tapLabButton(tester, 'btn_cb_runtime_prefetch');
    expect(controller.calls, ['prefetch([example_top_omaticka], 1500)']);

    await tester.tap(find.bySemanticsIdentifier('cb_tab_classic'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('cb_tab_runtime_lab'));
    await tester.pumpAndSettle();

    expect(find.text('example_top_omaticka'), findsOneWidget);
    expect(find.text('1500'), findsOneWidget);
    // The log is not kept when the lab unmounts (RN parity).
    expect(_statusText(tester), 'Runtime controller results will appear here.');

    await _tapLabButton(tester, 'btn_cb_runtime_prefetch');
    expect(_statusText(tester), contains('END prefetch'));
    await tester.ensureVisible(find.text('Clear log'));
    await tester.tap(find.text('Clear log'));
    await tester.pumpAndSettle();
    expect(_statusText(tester), 'Runtime controller results will appear here.');
  });

  tearDown(() {
    // Inputs are kept for the app session (RN parity); reset them between tests.
    RuntimeControllerLab.resetInputs();
  });
}
