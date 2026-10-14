import 'package:flutter/widgets.dart';

/// True when running under `flutter test` (no native WebView / platform views).
bool get isFlutterWidgetTest {
  return WidgetsBinding.instance.runtimeType
      .toString()
      .contains('AutomatedTestWidgetsFlutterBinding');
}
