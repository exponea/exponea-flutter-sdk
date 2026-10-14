import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

/// Brand parity with the Android example app (`ui/theme/Color.kt`,
/// `BrButton.kt`, `AuthScreen.kt`) — see ADR 2026-10-06-1400.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('palette mirrors Android example tokens', () {
    expect(BrandColors.yellow, const Color(0xFFFFD500));
    expect(BrandColors.black, const Color(0xFF111111));
    expect(BrandColors.grey100, const Color(0xFFF5F5F5));
    expect(BrandColors.grey600, const Color(0xFF666666));
  });

  test('theme uses yellow as primary fill with black on top', () {
    final theme = buildExampleAppTheme();
    expect(theme.colorScheme.primary, BrandColors.yellow);
    expect(theme.colorScheme.onPrimary, BrandColors.black);
    expect(theme.textSelectionTheme.cursorColor, BrandColors.black);
  });

  test('primary filled button is radius 8, height 44, bold', () {
    final style = buildExampleAppTheme().filledButtonTheme.style!;
    final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
    expect(shape.borderRadius, const BorderRadius.all(Radius.circular(8)));
    expect(style.minimumSize!.resolve({})!.height, 44);
    expect(style.textStyle!.resolve({})!.fontWeight, FontWeight.bold);
  });

  testWidgets('focused auth field border and label are not yellow', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: false);
    final fieldFinder = find.descendant(
      of: find.bySemanticsIdentifier('fld_auth_project_token'),
      matching: find.byType(TextField),
    );
    await tester.tap(fieldFinder);
    await tester.pumpAndSettle();

    final context = tester.element(fieldFinder);
    final decoration = tester
        .widget<TextField>(fieldFinder)
        .decoration!
        .applyDefaults(Theme.of(context).inputDecorationTheme);

    final focused = decoration.focusedBorder! as OutlineInputBorder;
    final enabled = decoration.enabledBorder! as OutlineInputBorder;
    expect(focused.borderSide.color, BrandColors.black);
    expect(enabled.borderSide.color, BrandColors.black);
    expect(decoration.floatingLabelStyle!.color, BrandColors.grey600);
    expect(focused.borderSide.color, isNot(BrandColors.yellow));
  });

  testWidgets('auth screen shows the official wordmark, no letter logo', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: false);
    final wordmark = tester.widget<BrandLogo>(find.byType(BrandLogo));
    expect(wordmark.size, 220);
    expect(find.text('b'), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('AppBar logo button renders the mini icon', (tester) async {
    await pumpExampleApp(tester, startOnShell: true);
    expect(
      find.descendant(
        of: find.bySemanticsIdentifier('btn_shell_logo'),
        matching: find.byType(BrandLogo),
      ),
      findsOneWidget,
    );
    expect(find.text('b'), findsNothing);
  });

  testWidgets('fetch buttons use Android labels with unchanged ids', (
    tester,
  ) async {
    await pumpExampleApp(tester, startOnShell: true);
    const expected = {
      'btn_fetch_consents': 'Fetch Consents',
      'btn_fetch_recommendations': 'Fetch Recommendations',
      'btn_fetch_segments': 'Fetch Segments',
    };
    for (final entry in expected.entries) {
      expect(
        find.descendant(
          of: find.bySemanticsIdentifier(entry.key),
          matching: find.text(entry.value),
        ),
        findsOneWidget,
        reason: '${entry.key} should read "${entry.value}"',
      );
    }
  });
}
