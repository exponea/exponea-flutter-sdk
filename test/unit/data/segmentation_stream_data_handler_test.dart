import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SegmentationStreamDataHandler', () {
    late SegmentationStreamDataHandler handler;
    late List<String> closedStreams;

    setUp(() {
      closedStreams = [];
      handler = SegmentationStreamDataHandler(
        onStreamClosed: (instanceId) => closedStreams.add(instanceId),
      );
    });

    test('registers and handles segmentation data', () async {
      const instanceId = 'mock_instance_id';
      final stream = handler.registerSegmentationDataStream(instanceId);

      final segments = [
        {'id': 'mock_id', 'segmentation_id': 'mock_segmentation_id'},
      ];

      final segmentationData = {
        'instanceId': instanceId,
        'data': segments,
      };

      expectLater(stream, emitsInOrder([segments]));
      handler.handleSegmentationData(segmentationData);
    });

    test('disposes segmentation data stream once it is closed', () async {
      const instanceOneId = 'mock_instance_id_1';
      const instanceTwoId = 'mock_instance_id_2';
      final streamOne = handler.registerSegmentationDataStream(instanceOneId);
      final streamTwo = handler.registerSegmentationDataStream(instanceTwoId);

      await streamOne.listen((_) {}).cancel();
      await streamOne.listen((_) {});

      expect(closedStreams, contains(instanceOneId));
      expect(closedStreams, isNot(contains(instanceTwoId)));

      // Attempt to handle new segmentation data after disposing the stream
      final segments = [
        {'id': 'mock_id', 'segmentation_id': 'mock_segmentation_id'},
      ];

      final segmentationDataOne = {
        'instanceId': instanceOneId,
        'data': segments,
      };

      final segmentationDataTwo = {
        'instanceId': instanceTwoId,
        'data': segments,
      };

      // Expect the stream to not emit new data after being disposed
      expectLater(streamOne, emitsDone);

      // Expect the second stream to still emit new data after stream one being disposed
      expectLater(streamTwo, emitsInOrder([segments]));

      handler.handleSegmentationData(segmentationDataOne);
      handler.handleSegmentationData(segmentationDataTwo);
    });

    test('does not call onStreamClosed when one of two subscriptions is canceled', () async {
      const instanceId = 'mock_instance_id';
      final stream = handler.registerSegmentationDataStream(instanceId);

      final subscriptionOne = stream.listen((_) {});
      final subscriptionTwo = stream.listen((_) {});

      await subscriptionOne.cancel();

      // Ensure onStreamClosed is not called when one of the two subscriptions is canceled
      expect(closedStreams, isNot(contains(instanceId)));

      // Cancel the second subscription to trigger onStreamClosed
      await subscriptionTwo.cancel();
      expect(closedStreams, contains(instanceId));
    });
  });
}