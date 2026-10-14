import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

/// Fake that throws a [PlatformException] on [configure], so we can test the
/// error dialog path without a native SDK.
class _ThrowingFakeExponeaService extends FakeExponeaService {
  final String errorMessage;
  _ThrowingFakeExponeaService({this.errorMessage = 'SDK init error'});

  @override
  Future<void> configure(ConfigureRequest request) async {
    throw PlatformException(code: 'CONFIGURE_ERROR', message: errorMessage);
  }
}

/// Records whether [clearLocalCustomerData] was called.
class _RecordingFakeExponeaService extends FakeExponeaService {
  bool clearCalled = false;

  @override
  Future<void> clearLocalCustomerData() async {
    clearCalled = true;
    return super.clearLocalCustomerData();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tapping a prefilled auth field selects its whole value', (
    tester,
  ) async {
    // Appium taps the field centre and deletes leftwards before typing; a caret
    // at the tap position kept the tail (e.g. `….exponea.com.exponea.com`).
    await pumpExampleApp(tester, startOnShell: false);
    const url = 'https://api.example.com';
    final field = find.descendant(
      of: find.bySemanticsIdentifier('fld_auth_api_url'),
      matching: find.byType(TextField),
    );
    await tester.enterText(field, url);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(field);
    await tester.pumpAndSettle();

    final controller = tester.widget<TextField>(field).controller!;
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: url.length),
    );
  });

  testWidgets('btn_auth_start is disabled when all required fields are empty', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpExampleApp(tester, startOnShell: false);

    expect(find.text('SDK Configuration'), findsOneWidget);

    final startSemantics = tester.getSemantics(
      find.bySemanticsIdentifier('btn_auth_start'),
    );
    expect(startSemantics.hasFlag(SemanticsFlag.isEnabled), isFalse);

    handle.dispose();
  });

  testWidgets(
    'btn_auth_start enables when project token, auth token, and base URL are filled',
    (tester) async {
      final handle = tester.ensureSemantics();
      await pumpExampleApp(tester, startOnShell: false);

      final tokenField = find.ancestor(
        of: find.text('Project token'),
        matching: find.byType(TextField),
      );
      final authField = find.ancestor(
        of: find.text('Authorization token'),
        matching: find.byType(TextField),
      );
      final urlField = find.ancestor(
        of: find.text('API URL'),
        matching: find.byType(TextField),
      );

      await tester.enterText(tokenField, 'test-project-token');
      await tester.pump();
      await tester.enterText(authField, 'test-auth-token');
      await tester.pump();
      await tester.enterText(urlField, 'https://api.example.com');
      await tester.pump();

      final startSemantics = tester.getSemantics(
        find.bySemanticsIdentifier('btn_auth_start'),
      );
      expect(startSemantics.hasFlag(SemanticsFlag.isEnabled), isTrue);

      handle.dispose();
    },
  );

  testWidgets('mode toggle shows stream fields and hides project fields', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: false);

    // Project mode by default — project token field visible.
    expect(find.ancestor(of: find.text('Project token'), matching: find.byType(TextField)), findsOneWidget);
    expect(find.ancestor(of: find.text('Stream ID'), matching: find.byType(TextField)), findsNothing);

    await tester.tap(find.bySemanticsIdentifier('btn_auth_mode_stream'));
    await tester.pumpAndSettle();

    // Stream mode — stream ID visible, project token hidden.
    expect(find.ancestor(of: find.text('Stream ID'), matching: find.byType(TextField)), findsOneWidget);
    expect(find.ancestor(of: find.text('Project token'), matching: find.byType(TextField)), findsNothing);
  });

  testWidgets('PlatformException from configure shows AlertDialog', (
    tester,
  ) async {
    const errorMsg = 'SDK init failed for testing';
    final service = _ThrowingFakeExponeaService(errorMessage: errorMsg);
    await pumpExampleApp(tester, service: service, startOnShell: false);

    // Fill all required fields to enable the start button.
    final tokenField = find.ancestor(
      of: find.text('Project token'),
      matching: find.byType(TextField),
    );
    final authField = find.ancestor(
      of: find.text('Authorization token'),
      matching: find.byType(TextField),
    );
    final urlField = find.ancestor(
      of: find.text('API URL'),
      matching: find.byType(TextField),
    );
    await tester.enterText(tokenField, 'test-project-token');
    await tester.pump();
    await tester.enterText(authField, 'test-auth-token');
    await tester.pump();
    await tester.enterText(urlField, 'https://api.example.com');
    await tester.pump();

    final startButton = find.bySemanticsIdentifier('btn_auth_start');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    // Use pump() steps instead of pumpAndSettle() to avoid timeout caused by
    // the CircularProgressIndicator's continuous animation while _loading = true.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(errorMsg), findsOneWidget);
    expect(find.text('SDK Configuration'), findsOneWidget);
  });

  testWidgets('btn_auth_clear_local_data calls service.clearLocalCustomerData', (
    tester,
  ) async {
    final service = _RecordingFakeExponeaService();
    await pumpExampleApp(tester, service: service, startOnShell: false);

    final clearButton = find.bySemanticsIdentifier('btn_auth_clear_local_data');
    await tester.ensureVisible(clearButton);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    expect(service.clearCalled, isTrue);
  });

  testWidgets('lbl_auth_title is present on auth screen', (tester) async {
    await pumpExampleApp(tester, startOnShell: false);

    expect(
      find.bySemanticsIdentifier('lbl_auth_title'),
      findsOneWidget,
      reason: 'The "SDK Configuration" title must have lbl_auth_title',
    );
  });

  testWidgets('project mode fld_auth_* fields are present by default', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: false);

    for (final id in [
      'fld_auth_project_token',
      'fld_auth_authorization_token',
      'fld_auth_advanced_auth',
      'fld_auth_registered_id',
      'fld_auth_api_url',
      'fld_auth_application_id',
    ]) {
      expect(
        find.bySemanticsIdentifier(id),
        findsOneWidget,
        reason: '$id must be present in project mode',
      );
    }
  });

  testWidgets('stream mode fld_auth_* fields are present after mode toggle', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: false);

    await tester.tap(find.bySemanticsIdentifier('btn_auth_mode_stream'));
    await tester.pumpAndSettle();

    for (final id in [
      'fld_auth_stream_id',
      'fld_auth_jwt_key_id',
      'fld_auth_jwt_secret',
      'fld_auth_registered_id',
      'fld_auth_api_url',
      'fld_auth_application_id',
    ]) {
      expect(
        find.bySemanticsIdentifier(id),
        findsOneWidget,
        reason: '$id must be present in stream mode',
      );
    }
  });

  testWidgets('btn_auth_error_ok is present in the config error dialog', (
    tester,
  ) async {
    const errorMsg = 'SDK init failed for testing';
    final service = _ThrowingFakeExponeaService(errorMessage: errorMsg);
    await pumpExampleApp(tester, service: service, startOnShell: false);

    final tokenField = find.ancestor(
      of: find.text('Project token'),
      matching: find.byType(TextField),
    );
    final authField = find.ancestor(
      of: find.text('Authorization token'),
      matching: find.byType(TextField),
    );
    final urlField = find.ancestor(
      of: find.text('API URL'),
      matching: find.byType(TextField),
    );
    await tester.enterText(tokenField, 'test-project-token');
    await tester.pump();
    await tester.enterText(authField, 'test-auth-token');
    await tester.pump();
    await tester.enterText(urlField, 'https://api.example.com');
    await tester.pump();

    final startButton = find.bySemanticsIdentifier('btn_auth_start');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.bySemanticsIdentifier('btn_auth_error_ok'),
      findsOneWidget,
      reason: 'Config error dialog OK button must expose btn_auth_error_ok',
    );
  });
}
