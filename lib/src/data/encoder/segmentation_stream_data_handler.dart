import 'dart:async';

class SegmentationStreamDataHandler {
  final Map<String, StreamController<List<Map<String, String>>>> _segmentationDataControllers = {};
  final void Function(String instanceId) onStreamClosed;

  SegmentationStreamDataHandler({required this.onStreamClosed});

  void handleSegmentationData(Map<dynamic, dynamic> segmentationData) {
    final String instanceId = segmentationData['instanceId'];
    final segments = (segmentationData['data'] as List).map((e) => Map<String, String>.from(e)).toList();
    _segmentationDataControllers[instanceId]?.add(segments);
  }

  Stream<List<Map<String, String>>> registerSegmentationDataStream(String instanceId) {
    final controller = StreamController<List<Map<String, String>>>.broadcast(
      onCancel: () => disposeSegmentationDataStream(instanceId),
    );
    _segmentationDataControllers[instanceId] = controller;
    return controller.stream;
  }

  void disposeSegmentationDataStream(String instanceId) {
    _segmentationDataControllers[instanceId]?.close();
    _segmentationDataControllers.remove(instanceId);
    onStreamClosed(instanceId);
  }
}