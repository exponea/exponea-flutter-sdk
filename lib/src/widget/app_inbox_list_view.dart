import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/encoder/app_inbox.dart';
import '../data/model/app_inbox_message.dart';

class AppInboxListView extends StatefulWidget {
  static const String _viewType = 'AppInboxListView';
  static const String _channelName = 'com.exponea/AppInboxListView';
  static const _methodOnAppInboxItemClicked = 'onAppInboxItemClicked';

  final Function(AppInboxMessage message) onAppInboxItemClicked;

  const AppInboxListView({
    Key? key,
    required this.onAppInboxItemClicked,
  }) : super(key: key);

  @override
  State<AppInboxListView> createState() => _AppInboxListViewState();
}

class _AppInboxListViewState extends State<AppInboxListView> {
  MethodChannel? _channel;

  Future<void> onPlatformViewCreated(id) async {
    _channel = MethodChannel('${AppInboxListView._channelName}/$id');
    _channel!.setMethodCallHandler(handleMethodCall);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case AppInboxListView._methodOnAppInboxItemClicked:
        final message = AppInboxCoder.decodeMessage(call.arguments);
        widget.onAppInboxItemClicked(message);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: AppInboxListView._viewType,
        onPlatformViewCreated: onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: AppInboxListView._viewType,
        onPlatformViewCreated: onPlatformViewCreated,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
