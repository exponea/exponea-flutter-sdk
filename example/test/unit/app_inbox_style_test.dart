import 'package:exponea_example/util/app_inbox_style.dart';
import 'package:flutter_test/flutter_test.dart';

/// Native App Inbox button parity with Android `ExampleAppInboxProvider`.
void main() {
  test('Android: brand colours, bold, 8dp radius converted to px', () {
    final button = buildExampleAppInboxStyle(
      isAndroid: true,
      devicePixelRatio: 3.0,
    ).appInboxButton!;

    expect(button.backgroundColor, '#FFD500');
    expect(button.textColor, '#111111');
    expect(button.textWeight, 'bold');
    expect(button.showIcon, isFalse);
    expect(button.textOverride, 'App Inbox (Native UI)');
    expect(button.borderRadius, '24px');
  });

  test('Android: radius follows device pixel ratio', () {
    final button = buildExampleAppInboxStyle(
      isAndroid: true,
      devicePixelRatio: 2.625,
    ).appInboxButton!;

    expect(button.borderRadius, '21px');
  });

  test('iOS: radius is sent as points', () {
    final button = buildExampleAppInboxStyle(
      isAndroid: false,
      devicePixelRatio: 3.0,
    ).appInboxButton!;

    expect(button.borderRadius, '8px');
  });
}
