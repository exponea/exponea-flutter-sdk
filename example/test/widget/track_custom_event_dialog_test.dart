import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/features/tracking/in_app_message_presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> openDialog(WidgetTester tester) async {
    await pumpExampleApp(tester, startOnShell: true, streamMode: true);
    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('btn_track_custom_event'));
    await tester.pumpAndSettle();
  }

  testWidgets('sel_inapp_preset is present when Track Custom Event dialog opens',
      (tester) async {
    await openDialog(tester);

    expect(
      find.bySemanticsIdentifier('sel_inapp_preset'),
      findsOneWidget,
      reason: 'Preset dropdown must expose sel_inapp_preset',
    );
  });

  testWidgets(
      'selecting Modal preset fills fld_event_name with test_event and '
      'lbl_event_props_json contains test_msg_modal', (tester) async {
    await openDialog(tester);

    // Open the dropdown and pick "Modal".
    await tester.tap(find.bySemanticsIdentifier('sel_inapp_preset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modal').last);
    await tester.pumpAndSettle();

    // Event name field should be updated.
    expect(
      find.descendant(
        of: find.bySemanticsIdentifier('fld_event_name'),
        matching: find.text('event_name'),
      ),
      findsOneWidget,
      reason: 'fld_event_name must show event_name after selecting Modal preset',
    );

    // Properties JSON panel should contain the preset property value.
    final jsonLabel = tester
        .widget<Semantics>(find.bySemanticsIdentifier('lbl_event_props_json'))
        .properties
        .label;
    expect(
      jsonLabel,
      contains('test_msg_modal'),
      reason:
          'lbl_event_props_json label must contain test_msg_modal after selecting Modal preset',
    );
  });

  testWidgets('every preset is on screen in the picker on a phone-sized display',
      (tester) async {
    // iPhone 17 logical size; off-screen rows stay in the semantics tree but a
    // tap on their coordinates selects nothing (Appium Stop SDK / AB presets).
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await openDialog(tester);

    await tester.tap(find.bySemanticsIdentifier('sel_inapp_preset'));
    await tester.pumpAndSettle();

    final screen = Offset.zero & const Size(402, 874);
    for (final label in inAppMessagePresets.map((p) => p.label)) {
      final rect = tester.getRect(find.text(label).last);
      expect(
        screen.contains(rect.topLeft) && screen.contains(rect.bottomRight),
        isTrue,
        reason: '$label must be fully visible in the preset picker ($rect)',
      );
    }
  });

  testWidgets('fld_event_name is read-only when a preset is selected',
      (tester) async {
    await openDialog(tester);

    await tester.tap(find.bySemanticsIdentifier('sel_inapp_preset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slide-in').last);
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(
      find.descendant(
        of: find.bySemanticsIdentifier('fld_event_name'),
        matching: find.byType(TextField),
      ),
    );
    expect(textField.readOnly, isTrue);
    expect(textField.decoration?.filled, isTrue);
    expect(textField.decoration?.fillColor, BrandColors.grey200);
  });

  testWidgets('fld_event_name is editable when (custom) is selected',
      (tester) async {
    await openDialog(tester);

    final field = find.bySemanticsIdentifier('fld_event_name');
    final textField = tester.widget<TextField>(
      find.descendant(of: field, matching: find.byType(TextField)),
    );
    expect(textField.readOnly, isFalse);

    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.enterText(field, 'my_custom_event');
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: field, matching: find.text('my_custom_event')),
      findsOneWidget,
    );
  });
}
