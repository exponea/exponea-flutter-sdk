import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// Every Tracking action must be on screen at the automation reference size: on iOS, Flutter
/// reports off-screen semantics nodes as hidden with a zero rect, so XCUITest taps on them miss.
/// iPhone 17 (the automation simulator): 402 x 874 logical, status bar 62, home indicator 34.
void _useIphone17Viewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(402, 874) * 3;
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(top: 62 * 3, bottom: 34 * 3);
  tester.view.viewPadding = const FakeViewPadding(top: 62 * 3, bottom: 34 * 3);
  addTearDown(tester.view.reset);
}

const _trackingActions = [
  'btn_identify_customer',
  'btn_set_auth_token',
  'btn_track_custom_event',
  'btn_track_payment',
  'btn_track_page_view',
  'btn_request_push',
  'btn_track_fcm_token',
  'btn_track_push_delivered',
  'btn_track_push_clicked',
];

void main() {
  testWidgets(
      'all tracking actions are above the bottom navigation on an iPhone 17 viewport',
      (tester) async {
    _useIphone17Viewport(tester);

    await pumpExampleApp(tester, startOnShell: true);
    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    final navTop =
        tester.getRect(find.bySemanticsIdentifier('btn_nav_tracking')).top;
    for (final id in _trackingActions) {
      final rect = tester.getRect(find.bySemanticsIdentifier(id));
      expect(
        rect.top >= 0 && rect.bottom <= navTop,
        isTrue,
        reason:
            '$id must be fully visible above the bottom navigation ($rect, nav top $navTop)',
      );
    }
  });

  testWidgets(
      'push request and FCM token share a row above delivered and clicked',
      (tester) async {
    _useIphone17Viewport(tester);

    await pumpExampleApp(tester, startOnShell: true);
    await tester.tap(find.bySemanticsIdentifier('btn_nav_tracking'));
    await tester.pumpAndSettle();

    Rect rectOf(String id) => tester.getRect(find.bySemanticsIdentifier(id));
    final request = rectOf('btn_request_push');
    final fcm = rectOf('btn_track_fcm_token');
    final delivered = rectOf('btn_track_push_delivered');
    final clicked = rectOf('btn_track_push_clicked');

    expect(request.top, moreOrLessEquals(fcm.top, epsilon: 1));
    expect(delivered.top, moreOrLessEquals(clicked.top, epsilon: 1));
    expect(request.bottom <= delivered.top, isTrue);
  });
}
