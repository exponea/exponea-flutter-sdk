import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('content blocks tab shows carousel toggle', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_content_blocks'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('btn_toggle_carousels'), findsOneWidget);
    expect(find.text('Placeholder: example_top'), findsOneWidget);
    expect(find.textContaining('Height:'), findsOneWidget);
    expect(find.text('Default carousel: example_carousel'), findsNothing);
  });

  testWidgets('toggle shows carousels and hides placeholders', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);

    await tester.tap(find.bySemanticsIdentifier('btn_nav_content_blocks'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsIdentifier('btn_toggle_carousels'));
    await tester.pumpAndSettle();

    expect(find.text('Default carousel: example_carousel'), findsOneWidget);
    expect(find.text('Carousel is empty'), findsOneWidget);
    expect(find.bySemanticsIdentifier('lbl_carousel_status'), findsOneWidget);
    expect(find.text('Placeholder: example_top'), findsNothing);
  });
}
