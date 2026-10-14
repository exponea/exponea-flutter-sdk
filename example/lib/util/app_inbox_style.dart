import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:exponea/exponea.dart';

/// Corner radius of primary buttons in logical pixels (Android `BrButton`).
const double _buttonRadius = 8;

/// App Inbox styling aligned with the Android example `ExampleAppInboxProvider`
/// (see ADR 2026-10-06-1400).
///
/// [isAndroid] and [devicePixelRatio] default to the current platform/view and
/// exist so tests can build the style deterministically.
AppInboxStyle buildExampleAppInboxStyle({
  bool? isAndroid,
  double? devicePixelRatio,
}) {
  final android = isAndroid ?? Platform.isAndroid;
  // The native Android SDK applies `borderRadius` as raw pixels and ignores the
  // unit (ButtonStyle.apply() uses only the parsed number), so convert dp → px
  // here. iOS applies the number as points, which is already what we want.
  final dpr = devicePixelRatio ??
      PlatformDispatcher.instance.views.first.devicePixelRatio;
  final radius =
      android ? (_buttonRadius * dpr).round() : _buttonRadius.round();
  return AppInboxStyle(
    appInboxButton: SimpleButtonStyle(
      backgroundColor: '#FFD500',
      borderRadius: '${radius}px',
      showIcon: false,
      enabled: true,
      textSize: '14sp',
      textOverride: 'App Inbox (Native UI)',
      textWeight: 'bold',
      textColor: '#111111',
    ),
    listView: ListScreenStyle(
      list: AppInboxListViewStyle(
        backgroundColor: '#EEEEEE',
        item: AppInboxListItemStyle(
          backgroundColor: '#FFFFFF',
          content: TextViewStyle(
            textColor: '#111111',
            textWeight: '400',
          ),
        ),
      ),
    ),
    detailView: DetailViewStyle(
      title: TextViewStyle(
        textSize: '18sp',
        textWeight: 'bold',
        textColor: '#111111',
      ),
      button: SimpleButtonStyle(
        backgroundColor: '#009ACE',
        textColor: '#FFFFFF',
      ),
    ),
  );
}
