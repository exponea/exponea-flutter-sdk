import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('open inbox navigates to list page', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_open_inbox'));
    await tester.pumpAndSettle();

    expect(find.text('App inbox'), findsOneWidget);
  });

  testWidgets('App inbox list page exposes lbl_app_inbox_title', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_open_inbox'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('lbl_app_inbox_title'),
      findsOneWidget,
      reason: 'AppBar title must expose lbl_app_inbox_title',
    );
  });

  testWidgets('App inbox list page exposes btn_app_inbox_back', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_open_inbox'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('btn_app_inbox_back'),
      findsOneWidget,
      reason: 'AppBar back button must expose btn_app_inbox_back',
    );
  });

  testWidgets('App inbox list page exposes list_app_inbox host wrapper', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_open_inbox'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('list_app_inbox'),
      findsOneWidget,
      reason:
          'AppInboxListView host wrapper must expose list_app_inbox identifier',
    );
  });
}
