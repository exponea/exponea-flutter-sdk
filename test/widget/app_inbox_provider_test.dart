import 'package:exponea/src/widget/app_inbox_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppInboxProvider', () {
    group('on unsupported platform', () {
      testWidgets('renders SizedBox.shrink', (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        try {
          await tester.pumpWidget(
            const MaterialApp(home: AppInboxProvider()),
          );

          expect(find.byType(SizedBox), findsWidgets);
          expect(find.byType(AndroidView), findsNothing);
          expect(find.byType(UiKitView), findsNothing);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    });

    group('on Android', () {
      testWidgets('renders AndroidView with correct viewType',
          (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        try {
          await tester.pumpWidget(
            const MaterialApp(home: AppInboxProvider()),
          );

          final androidView =
              tester.widget<AndroidView>(find.byType(AndroidView));
          expect(androidView.viewType, equals(AppInboxProvider.viewType));
          expect(find.byType(UiKitView), findsNothing);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    });

    group('on iOS', () {
      testWidgets('renders UiKitView with correct viewType',
          (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        try {
          await tester.pumpWidget(
            const MaterialApp(home: AppInboxProvider()),
          );

          final iosView = tester.widget<UiKitView>(find.byType(UiKitView));
          expect(iosView.viewType, equals(AppInboxProvider.viewType));
          expect(find.byType(AndroidView), findsNothing);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    });

    testWidgets('viewType constant is stable', (WidgetTester tester) async {
      expect(AppInboxProvider.viewType, equals('FluffView'));
    });
  });
}
