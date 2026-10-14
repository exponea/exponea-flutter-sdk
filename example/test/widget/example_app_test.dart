import 'package:exponea_example/main.dart';
import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:exponea_example/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('img_loading_logo is present on LoadingScreen', (tester) async {
    // Pump without skipLoading so the app starts at the loading screen.
    // The 100 ms delayed route-resolve hasn't fired yet after pumpWidget.
    await tester.pumpWidget(
      buildExampleApp(service: FakeExponeaService(), skipLoading: false),
    );
    // One extra pump to process the first frame (but not the 100 ms delay).
    await tester.pump();

    expect(
      find.bySemanticsIdentifier('img_loading_logo'),
      findsOneWidget,
      reason: 'LoadingScreen logo must expose img_loading_logo',
    );
    expect(
      find.descendant(
        of: find.bySemanticsIdentifier('img_loading_logo'),
        matching: find.byType(BrandLogo),
      ),
      findsOneWidget,
      reason: 'Loading logo must be the official mini icon asset',
    );
    expect(find.byType(CircleAvatar), findsNothing);

    // Advance past the 100 ms timer to avoid "timer still pending" assertion.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  });
}
