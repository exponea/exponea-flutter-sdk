import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/encoder/in_app_content_block.dart';
import '../data/encoder/in_app_content_block_action.dart';
import '../data/model/in_app_content_block_action.dart';
import '../data/model/in_app_content_block.dart';

class InAppContentBlockPlaceholder extends StatefulWidget {
  final String placeholderId;
  final bool overrideDefaultBehavior;
  final double? maxWidth;
  final double? maxHeight;
  final Function(String placeholderId, InAppContentBlock contentBlock, InAppContentBlockAction action)? onActionClicked;
  final Function(String placeholderId, InAppContentBlock contentBlock)? onCloseClicked;
  final Function(String placeholderId, InAppContentBlock contentBlock, String errorMessage)? onError;
  final Function(String placeholderId, InAppContentBlock contentBlock)? onMessageShown;
  final Function(String placeholderId)? onNoMessageFound;

  const InAppContentBlockPlaceholder({
    Key? key,
    required this.placeholderId,
    this.overrideDefaultBehavior = false,
    this.maxWidth,
    this.maxHeight,
    this.onActionClicked,
    this.onCloseClicked,
    this.onError,
    this.onMessageShown,
    this.onNoMessageFound,
  }) : super(key: key);

  @override
  State<InAppContentBlockPlaceholder> createState() => _InAppContentBlockPlaceholderState();
}

class _InAppContentBlockPlaceholderState extends State<InAppContentBlockPlaceholder> {
  int _id = 0;
  double _height = 1;

  static const String _viewType = 'InAppContentBlockPlaceholder';
  static const String _channelName = 'com.exponea/InAppContentBlockPlaceholder';
  static const _methodOnInAppContentBlockHtmlChanged = 'onInAppContentBlockHtmlChanged';
  static const _methodOnInAppContentBlockAction = 'onInAppContentBlockEvent';
  static const _handleInAppContentBlockClick = 'handleInAppContentBlockClick';

  MethodChannel? _channel;
  Widget? platformView;

  late WebViewController controller;

  _InAppContentBlockPlaceholderState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (x) async {
            controller.runJavaScript('if (!!document.body && !!document.body.style) { document.body.style.overflow = \'hidden\'; }');
            var scrollHeightObj = await controller.runJavaScriptReturningResult("(!!document.documentElement && document.documentElement.scrollHeight) || 0");
            double? scrollHeight = double.tryParse(scrollHeightObj.toString());
            if (!mounted) return;
            if (scrollHeight != null) {
              setState(() {
                _height = scrollHeight;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if(request.url == 'about:blank') {
              return NavigationDecision.navigate;
            }
            _channel!.invokeMethod(_handleInAppContentBlockClick, {"actionUrl": request.url});
            return NavigationDecision.prevent;
          },
        ),
      );
  }

  Future<void> onPlatformViewCreated(id) async {
    _id = id;
    _channel = MethodChannel('$_channelName/$id');
    _channel!.setMethodCallHandler(handleMethodCall);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case _methodOnInAppContentBlockHtmlChanged:
        var htmlContent = call.arguments['htmlContent'];
        if (htmlContent == null || htmlContent!.isEmpty) {
          controller.loadHtmlString("<html><body></body></html>");
        } else {
          controller.loadHtmlString(htmlContent!);
        }
        break;
      case _methodOnInAppContentBlockAction:
        try {
          final eventType = call.arguments['eventType'];
          final placeholderId = call.arguments['placeholderId'];
          switch (eventType) {
            case 'onActionClicked':
              final contentBlock = InAppContentBlockEncoder.decode(jsonDecode(call.arguments['contentBlock']));
              final action = InAppContentBlockActionEncoder.decode(call.arguments['action']);
              widget.onActionClicked?.call(placeholderId, contentBlock, action);
              break;
            case 'onCloseClicked':
              final contentBlock = InAppContentBlockEncoder.decode(jsonDecode(call.arguments['contentBlock']));
              widget.onCloseClicked?.call(placeholderId, contentBlock);
              break;
            case 'onError':
              final contentBlock = InAppContentBlockEncoder.decode(jsonDecode(call.arguments['contentBlock']));
              final errorMessage = call.arguments['errorMessage'];
              widget.onError?.call(placeholderId, contentBlock, errorMessage);
              break;
            case 'onMessageShown':
              final contentBlock = InAppContentBlockEncoder.decode(jsonDecode(call.arguments['contentBlock']));
              widget.onMessageShown?.call(placeholderId, contentBlock);
              break;
            case 'onNoMessageFound':
              widget.onNoMessageFound?.call(placeholderId);
              break;
          }
        } catch (_) {}
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
    if (platformView == null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformView = AndroidView(
          viewType: _viewType,
          creationParams: {
            'placeholderId': widget.placeholderId,
            'overrideDefaultBehavior': widget.overrideDefaultBehavior,
          },
          onPlatformViewCreated: onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec(),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView =  UiKitView(
          viewType: _viewType,
          creationParams: {
            'placeholderId': widget.placeholderId,
            'overrideDefaultBehavior': widget.overrideDefaultBehavior
          },
          onPlatformViewCreated: onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec(),
        );
      } else {
        platformView = SizedBox.shrink();
      }
    }
    return Column(
      children: [
        Visibility(
          visible: false,
          maintainState: true,
          child: SizedBox(
            width: widget.maxWidth ?? double.infinity,
            height: 1,
            child: platformView,
          ),
        ),
        SizedBox(
          width: widget.maxWidth ?? double.infinity,
          height: min(_height, widget.maxHeight ?? double.infinity),
          child: WebViewWidget(
            controller: controller,
            gestureRecognizers: {}..add(Factory(() => VerticalDragGestureRecognizer())),
          ),
        ),
      ],
    );
  }
}
