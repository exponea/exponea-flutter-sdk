import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppContentBlockPlaceholder extends StatefulWidget {
  final String placeholderId;
  final double? maxWidth;
  final double? maxHeight;

  const InAppContentBlockPlaceholder({
    Key? key,
    required this.placeholderId,
    this.maxWidth,
    this.maxHeight,
  }) : super(key: key);

  @override
  State<InAppContentBlockPlaceholder> createState() => _InAppContentBlockPlaceholderState();
}

class _InAppContentBlockPlaceholderState extends State<InAppContentBlockPlaceholder> {
  int _id = 0;
  double _height = 1;
  String? htmlContent;

  static const String _viewType = 'InAppContentBlockPlaceholder';
  static const String _channelName = 'com.exponea/InAppContentBlockPlaceholder';
  static const _methodOnInAppContentBlockHtmlChanged = 'onInAppContentBlockHtmlChanged';
  static const _handleInAppContentBlockClick = 'handleInAppContentBlockClick';

  MethodChannel? _channel;

  late WebViewController controller;

  Future<void> onPlatformViewCreated(id) async {
    _id = id;
    _channel = MethodChannel('$_channelName/$id');
    _channel!.setMethodCallHandler(handleMethodCall);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case _methodOnInAppContentBlockHtmlChanged:
        setState(() {
          htmlContent = call.arguments['htmlContent'];
          if (htmlContent != null) {
            controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onPageFinished: (x) async {
                    controller.runJavaScript('document.body.style.overflow = \'hidden\';');
                    var x = await controller.runJavaScriptReturningResult("document.documentElement.scrollHeight");

                    double? y = double.tryParse(x.toString());
                    if (!mounted) return;
                    setState(() {
                      if (y != null) {
                        _height = y;
                      }
                    });
                  },
                  onNavigationRequest: (NavigationRequest request) {
                    if(request.url == 'about:blank') {
                      return NavigationDecision.navigate;
                    }
                    _channel!.invokeMethod(_handleInAppContentBlockClick, {"actionUrl": request.url});
                    return NavigationDecision.prevent;
                  },
                ),
              )
              ..loadHtmlString(htmlContent!);
          }
        });
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
    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.android) {
      platformView = AndroidView(
        viewType: _viewType,
        creationParams: {
          'placeholderId': widget.placeholderId,
        },
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView =  UiKitView(
        viewType: _viewType,
        creationParams: {
          'placeholderId': widget.placeholderId,
        },
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return const SizedBox.shrink();
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
        htmlContent != null && htmlContent!.isNotEmpty
            ? SizedBox(
                width: widget.maxWidth ?? double.infinity,
                height: min(_height, widget.maxHeight ?? double.infinity),
                child: WebViewWidget(
                  controller: controller,
                  gestureRecognizers: {}..add(Factory(() => VerticalDragGestureRecognizer())),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
