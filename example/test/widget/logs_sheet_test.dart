import 'package:exponea_example/logging/log_record.dart';
import 'package:exponea_example/logging/sdk_log_store.dart';
import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('logs sheet shows merged SDK and app logs', (tester) async {
    final service = FakeExponeaService();
    service.appendLog('App action logged');
    final logStore = SdkLogStore();
    logStore.add(
      LogRecord(
        time: DateTime(2026, 6, 26, 10, 0, 0),
        level: SdkLogLevel.debug,
        tag: 'ExponeaSDK',
        message: 'SDK debug line',
      ),
    );

    await pumpExampleApp(
      tester,
      service: service,
      sdkLogStore: logStore,
      startOnShell: true,
    );

    await tester.tap(find.bySemanticsIdentifier('btn_open_logs'));
    await tester.pumpAndSettle();

    expect(find.text('SDK debug line'), findsOneWidget);
    expect(find.text('App action logged'), findsOneWidget);
    expect(find.text('D'), findsWidgets);
  });

  testWidgets('debug filter hides info app logs', (tester) async {
    final service = FakeExponeaService();
    service.appendLog('App info line');
    final logStore = SdkLogStore();
    logStore.add(
      LogRecord(
        time: DateTime(2026, 6, 26, 10, 0, 0),
        level: SdkLogLevel.debug,
        tag: 'ExponeaSDK',
        message: 'SDK debug line',
      ),
    );

    await pumpExampleApp(
      tester,
      service: service,
      sdkLogStore: logStore,
      startOnShell: true,
    );

    await tester.tap(find.bySemanticsIdentifier('btn_open_logs'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('D').first);
    await tester.pumpAndSettle();

    expect(find.text('SDK debug line'), findsOneWidget);
    expect(find.text('App info line'), findsNothing);
  });

  testWidgets('clear removes visible logs', (tester) async {
    final service = FakeExponeaService();
    service.appendLog('Will be cleared');
    final logStore = SdkLogStore();

    await pumpExampleApp(
      tester,
      service: service,
      sdkLogStore: logStore,
      startOnShell: true,
    );

    await tester.tap(find.bySemanticsIdentifier('btn_open_logs'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clear logs'));
    await tester.pumpAndSettle();

    expect(find.text('Will be cleared'), findsNothing);
    expect(service.logs, isEmpty);
    expect(logStore.records, isEmpty);
  });

  testWidgets('lbl_logs_empty is present when no logs in sheet', (
    tester,
  ) async {
    final service = FakeExponeaService();
    service.clearLogs();

    await pumpExampleApp(tester, service: service, startOnShell: true);

    // Clear logs added during startup (e.g. trackPageView from AppShell.initState).
    service.clearLogs();

    await tester.tap(find.bySemanticsIdentifier('btn_open_logs'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('lbl_logs_empty'),
      findsOneWidget,
      reason: 'Empty-state message must expose lbl_logs_empty when no logs',
    );
  });

  testWidgets('list_logs is present when logs are seeded', (tester) async {
    final service = FakeExponeaService();
    service.appendLog('Test log line');
    final logStore = SdkLogStore();
    logStore.add(
      LogRecord(
        time: DateTime(2026, 1, 1, 10),
        level: SdkLogLevel.info,
        tag: 'SDK',
        message: 'SDK info message',
      ),
    );

    await pumpExampleApp(
      tester,
      service: service,
      sdkLogStore: logStore,
      startOnShell: true,
    );

    await tester.tap(find.bySemanticsIdentifier('btn_open_logs'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('list_logs'),
      findsOneWidget,
      reason: 'ListView must expose list_logs when there are log entries',
    );
  });

  testWidgets('btn_logs_copy/clear/close are present in logs sheet', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_open_logs'));
    await tester.pumpAndSettle();

    for (final id in ['btn_logs_copy', 'btn_logs_clear', 'btn_logs_close']) {
      expect(
        find.bySemanticsIdentifier(id),
        findsOneWidget,
        reason: '$id must be present in the logs sheet header',
      );
    }
  });

  testWidgets('filter chips expose btn_logs_filter_* identifiers', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_open_logs'));
    await tester.pumpAndSettle();

    for (final id in [
      'btn_logs_filter_all',
      'btn_logs_filter_verbose',
      'btn_logs_filter_debug',
      'btn_logs_filter_info',
      'btn_logs_filter_warn',
      'btn_logs_filter_error',
    ]) {
      expect(
        find.bySemanticsIdentifier(id),
        findsOneWidget,
        reason: '$id must be present in the logs filter bar',
      );
    }
  });
}
