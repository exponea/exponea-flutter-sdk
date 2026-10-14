import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// Helper: navigate to the flushing screen.
Future<void> _openFlushing(WidgetTester tester) async {
  await pumpExampleApp(tester, startOnShell: true);
  await tester.tap(find.bySemanticsIdentifier('btn_nav_flushing'));
  await tester.pumpAndSettle();
}

void main() {
  // ── Tab row ──────────────────────────────────────────────────────────────

  testWidgets('tab row: all three tab buttons are present', (tester) async {
    await _openFlushing(tester);

    expect(find.bySemanticsIdentifier('btn_flush_tab_flush_mode'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_flush_tab_flush_period'), findsOneWidget);
    expect(find.bySemanticsIdentifier('btn_flush_tab_log_level'), findsOneWidget);
  });

  testWidgets(
      'tab row: initially Flush Mode content is visible, other tabs hidden',
      (tester) async {
    await _openFlushing(tester);

    expect(find.bySemanticsIdentifier('btn_get_flush_mode'), findsOneWidget,
        reason: 'Flush Mode content must be visible on initial render');
    expect(find.bySemanticsIdentifier('btn_get_flush_period'), findsNothing,
        reason: 'Flush Period content must be hidden initially');
    expect(find.bySemanticsIdentifier('btn_get_log_level'), findsNothing,
        reason: 'Log Level content must be hidden initially');
  });

  testWidgets('tab row: tapping Flush Period tab shows period content',
      (tester) async {
    await _openFlushing(tester);

    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_flush_period'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_get_flush_period'), findsOneWidget,
        reason: 'Flush Period content must appear after tapping its tab');
    expect(find.bySemanticsIdentifier('btn_get_flush_mode'), findsNothing,
        reason: 'Flush Mode content must be hidden when Flush Period tab is active');
  });

  testWidgets('tab row: tapping Log Level tab shows log level content',
      (tester) async {
    await _openFlushing(tester);

    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_log_level'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_get_log_level'), findsOneWidget,
        reason: 'Log Level content must appear after tapping its tab');
    expect(find.bySemanticsIdentifier('btn_get_flush_mode'), findsNothing,
        reason: 'Flush Mode content must be hidden when Log Level tab is active');
  });

  testWidgets(
      'tab row: semantics activate on Log Level tab shows get log level',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _openFlushing(tester);

    final data = tester
        .getSemantics(find.bySemanticsIdentifier('btn_flush_tab_log_level'))
        .getSemanticsData();
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_log_level'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_get_log_level'), findsOneWidget);
    handle.dispose();
  });

  testWidgets(
      'tab row: semantics activate on Period tab shows get flush period',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _openFlushing(tester);

    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_flush_period'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_get_flush_period'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('tab row: switching back to Flush Mode tab restores mode content',
      (tester) async {
    await _openFlushing(tester);

    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_log_level'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_flush_mode'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_get_flush_mode'), findsOneWidget,
        reason: 'Flush Mode content must reappear after switching back');
    expect(find.bySemanticsIdentifier('btn_get_log_level'), findsNothing,
        reason: 'Log Level content must be hidden after switching away');
  });

  // ── Existing tests (updated for tab navigation) ──────────────────────────

  testWidgets('flushing tab shows flush data button', (tester) async {
    await _openFlushing(tester);

    // btn_flush_data is on the Flush Period tab.
    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_flush_period'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_flush_data'), findsOneWidget);
    // btn_flush_mode_immediate is on the Flush Mode tab — switch back to verify.
    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_flush_mode'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('btn_flush_mode_immediate'), findsOneWidget);
  });

  testWidgets('get flush mode shows SnackBar with current mode', (tester) async {
    await _openFlushing(tester);

    await tester.tap(find.bySemanticsIdentifier('btn_get_flush_mode'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('Current mode: IMMEDIATE'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('get flush period warns when mode is not period', (tester) async {
    await _openFlushing(tester);

    // btn_get_flush_period is on the Flush Period tab.
    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_flush_period'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_get_flush_period'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.textContaining('requires PERIOD mode'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('get flush period shows value after switching to period mode',
      (tester) async {
    await _openFlushing(tester);

    // Set PERIOD mode on the Flush Mode tab (default).
    await tester.tap(find.bySemanticsIdentifier('btn_flush_mode_period'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));

    // Switch to Flush Period tab to read the period value.
    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_flush_period'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_get_flush_period'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('Current period: 30 seconds'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('lbl_current_flush_mode is present on flushing screen', (
    tester,
  ) async {
    await _openFlushing(tester);

    expect(
      find.bySemanticsIdentifier('lbl_current_flush_mode'),
      findsOneWidget,
      reason: 'Flush mode status box must expose lbl_current_flush_mode',
    );
  });

  testWidgets('lbl_current_flush_period is present on flushing screen', (
    tester,
  ) async {
    await _openFlushing(tester);

    // lbl_current_flush_period is on the Flush Period tab.
    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_flush_period'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('lbl_current_flush_period'),
      findsOneWidget,
      reason: 'Flush period status box must expose lbl_current_flush_period',
    );
  });

  testWidgets('lbl_current_log_level is present on flushing screen', (
    tester,
  ) async {
    await _openFlushing(tester);

    // lbl_current_log_level is on the Log Level tab.
    await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_log_level'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('lbl_current_log_level'),
      findsOneWidget,
      reason: 'Log level status box must expose lbl_current_log_level',
    );
  });

  testWidgets(
    'iOS INFO maps to native VERBOSE but lbl shows INFO',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final fake = FakeExponeaService();
        await pumpExampleApp(tester, service: fake, startOnShell: true);
        await tester.tap(find.bySemanticsIdentifier('btn_nav_flushing'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_log_level'));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsIdentifier('btn_log_info'));
        await tester.pumpAndSettle();

        expect(
          fake.logs.any(
            (line) => line.contains('Fake setLogLevel(LogLevel.verbose)'),
          ),
          isTrue,
          reason: 'iOS INFO must call setLogLevel(VERBOSE)',
        );
        expect(
          find.textContaining('Current log level: INFO'),
          findsOneWidget,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'Android INFO calls setLogLevel(INFO) and lbl shows INFO',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final fake = FakeExponeaService();
        await pumpExampleApp(tester, service: fake, startOnShell: true);
        await tester.tap(find.bySemanticsIdentifier('btn_nav_flushing'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_log_level'));
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsIdentifier('btn_log_info'));
        await tester.pumpAndSettle();

        expect(
          fake.logs.any(
            (line) => line.contains('Fake setLogLevel(LogLevel.info)'),
          ),
          isTrue,
          reason: 'Android INFO must call setLogLevel(INFO) without remapping',
        );
        expect(
          find.textContaining('Current log level: INFO'),
          findsOneWidget,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'flush result dialog exposes lbl_flush_result_title and btn_flush_result_ok',
    (tester) async {
      await _openFlushing(tester);

      // Switch to MANUAL mode (on the Flush Mode tab — default).
      await tester.tap(find.bySemanticsIdentifier('btn_flush_mode_manual'));
      await tester.pumpAndSettle();

      // btn_flush_data is on the Flush Period tab — switch to it.
      await tester.tap(find.bySemanticsIdentifier('btn_flush_tab_flush_period'));
      await tester.pumpAndSettle();

      final flushButton = find.bySemanticsIdentifier('btn_flush_data');
      await tester.ensureVisible(flushButton);
      await tester.pumpAndSettle();

      await tester.tap(flushButton);
      // Use pump() steps instead of pumpAndSettle() because the
      // LinearProgressIndicator that appears while _flushing=true continuously
      // animates and would cause pumpAndSettle to time out.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.bySemanticsIdentifier('lbl_flush_result_title'),
        findsOneWidget,
        reason: 'Flush result dialog title must expose lbl_flush_result_title',
      );
      expect(
        find.bySemanticsIdentifier('btn_flush_result_ok'),
        findsOneWidget,
        reason: 'Flush result dialog OK button must expose btn_flush_result_ok',
      );
    },
  );
}
