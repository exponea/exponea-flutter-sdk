import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/encoder/in_app_content_block.dart';
import '../data/encoder/in_app_content_block_action.dart';
import '../data/model/in_app_content_block.dart';
import '../data/model/in_app_content_block_action.dart';

class InAppContentBlockCarousel extends StatefulWidget {
  final String placeholderId;
  final bool overrideDefaultBehavior;
  final bool trackActions;
  final int? maxMessagesCount;
  final int? scrollDelay;
  final double? maxWidth;
  final double? maxHeight;
  final Function(String placeholderId, InAppContentBlock contentBlock, InAppContentBlockAction action)? onActionClicked;
  final Function(String placeholderId, InAppContentBlock contentBlock)? onCloseClicked;
  final Function(String placeholderId, InAppContentBlock contentBlock, String errorMessage)? onError;
  final Function(String placeholderId, InAppContentBlock contentBlock, int index, int count)? onMessageShown;
  final Function(int count, List<InAppContentBlock> messages)? onMessagesChanged;
  final Function(String placeholderId)? onNoMessageFound;
  final Function(String placeholderId, double height)? onHeightUpdate;
  final List<InAppContentBlock> Function(List<InAppContentBlock> contentBlocks)? filterContentBlocks;
  final List<InAppContentBlock> Function(List<InAppContentBlock> contentBlocks)? sortContentBlocks;

  const InAppContentBlockCarousel({
    Key? key,
    required this.placeholderId,
    this.overrideDefaultBehavior = false,
    this.trackActions = true,
    this.maxMessagesCount,
    this.scrollDelay,
    this.maxWidth,
    this.maxHeight,
    this.onActionClicked,
    this.onCloseClicked,
    this.onError,
    this.onMessageShown,
    this.onMessagesChanged,
    this.onNoMessageFound,
    this.onHeightUpdate,
    this.filterContentBlocks,
    this.sortContentBlocks,
  }) : super(key: key);

  @override
  State<InAppContentBlockCarousel> createState() => _InAppContentBlockCarouselState();
}

class _InAppContentBlockCarouselState extends State<InAppContentBlockCarousel> {
  int _id = 0;
  double _height = 1;

  static const String _viewType = 'InAppContentBlockCarousel';
  static const String _channelName = 'com.exponea/InAppContentBlockCarousel';
  static const _methodOnInAppContentBlockCarouselEvent = 'onInAppContentBlockCarouselEvent';
  static const _methodFilterContentBlocks = 'filterContentBlocks';
  static const _methodSortContentBlocks = 'sortContentBlocks';


  MethodChannel? _channel;
  Widget? platformView;

  Future<void> onPlatformViewCreated(id) async {
    _id = id;
    _channel = MethodChannel('$_channelName/$id');
    _channel!.setMethodCallHandler(handleMethodCall);
  }

  Future<void> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case _methodOnInAppContentBlockCarouselEvent:
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
              final index = call.arguments['index'];
              final count = call.arguments['count'];
              widget.onMessageShown?.call(placeholderId, contentBlock, index, count);
              break;
            case 'onMessagesChanged':
              final count = call.arguments['count'];
              final messages = (call.arguments['messages'] as List).map((e) => InAppContentBlockEncoder.decode(jsonDecode(e))).toList();
              widget.onMessagesChanged?.call(count, messages);
              break;
            case 'onNoMessageFound':
              widget.onNoMessageFound?.call(placeholderId);
              break;
            case 'onHeightUpdate':
              final double newHeight = call.arguments['height'].toDouble();
              if (!mounted) {
                return;
              }
              setState(() {
                if (defaultTargetPlatform == TargetPlatform.android) {
                  _height = newHeight > 0
                      ? newHeight / MediaQuery.of(context).devicePixelRatio
                      : 1;
                } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                  _height = newHeight > 0 ? newHeight : 1;
                }
              });
              widget.onHeightUpdate?.call(placeholderId, _height);
              break;
          }
        } catch (_) {}
        break;
      case _methodFilterContentBlocks:
        try {
          final contentBlocks = (call.arguments as List).map((e) => InAppContentBlockEncoder.decode(jsonDecode(e))).toList();
          final result = widget.filterContentBlocks?.call(contentBlocks);
          _channel?.invokeListMethod('filterContentBlocksResult', result!.map((e) => jsonEncode(InAppContentBlockEncoder.encode(e))).toList());
        } catch (_) {}
        break;
      case _methodSortContentBlocks:
        try {
          final contentBlocks = (call.arguments as List).map((e) => InAppContentBlockEncoder.decode(jsonDecode(e))).toList();
          final result = widget.sortContentBlocks?.call(contentBlocks);
          _channel?.invokeListMethod('sortContentBlocksResult', result!.map((e) => jsonEncode(InAppContentBlockEncoder.encode(e))).toList());
        } catch (_) {}
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    platformView = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (platformView == null) {
      final creationParams = {
        'placeholderId': widget.placeholderId,
        'overrideDefaultBehavior': widget.overrideDefaultBehavior,
        'trackActions': widget.trackActions,
        'maxMessagesCount': widget.maxMessagesCount,
        'scrollDelay': widget.scrollDelay,
        'filtrationSet': widget.filterContentBlocks != null,
        'sortingSet': widget.sortContentBlocks != null,
      };
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformView = AndroidView(
          viewType: _viewType,
          creationParams: creationParams,
          onPlatformViewCreated: onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec(),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView = UiKitView(
          viewType: _viewType,
          creationParams: creationParams,
          onPlatformViewCreated: onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec(),
        );
      } else {
        platformView = const SizedBox.shrink();
      }
    }
    return SizedBox(
      width: widget.maxWidth ?? double.infinity,
      height: min(_height, widget.maxHeight ?? double.infinity),
      child: platformView,
    );
  }
}
