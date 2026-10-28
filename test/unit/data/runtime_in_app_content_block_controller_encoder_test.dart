import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InAppContentBlockAvailabilityEncoder', () {
    test('decodes known availability values', () {
      expect(InAppContentBlockAvailabilityEncoder.decode('ready'),
          InAppContentBlockAvailability.ready);
      expect(InAppContentBlockAvailabilityEncoder.decode('loading'),
          InAppContentBlockAvailability.loading);
      expect(InAppContentBlockAvailabilityEncoder.decode('empty'),
          InAppContentBlockAvailability.empty);
    });

    test('unknown availability collapses to loading', () {
      expect(InAppContentBlockAvailabilityEncoder.decode('parsing'),
          InAppContentBlockAvailability.loading);
      expect(InAppContentBlockAvailabilityEncoder.decode(null),
          InAppContentBlockAvailability.loading);
      expect(InAppContentBlockAvailabilityEncoder.decode(42),
          InAppContentBlockAvailability.loading);
    });

    test('decodes a prefetch map', () {
      final result = InAppContentBlockAvailabilityEncoder.decodePrefetch({
        'a': 'ready',
        'b': 'empty',
        'c': 'loading',
      });

      expect(result, {
        'a': InAppContentBlockAvailability.ready,
        'b': InAppContentBlockAvailability.empty,
        'c': InAppContentBlockAvailability.loading,
      });
    });

    test('unknown prefetch value collapses to loading', () {
      final result = InAppContentBlockAvailabilityEncoder.decodePrefetch({
        'a': 'parsing',
      });

      expect(result, {'a': InAppContentBlockAvailability.loading});
    });

    test('decodes a resolved decision', () {
      expect(
        InAppContentBlockAvailabilityEncoder.decodeDecision({
          'status': 'resolved',
          'availability': 'ready',
        }),
        const InAppContentBlockAvailabilityResolved(
            InAppContentBlockAvailability.ready),
      );
      expect(
        InAppContentBlockAvailabilityEncoder.decodeDecision({
          'status': 'resolved',
          'availability': 'empty',
        }),
        const InAppContentBlockAvailabilityResolved(
            InAppContentBlockAvailability.empty),
      );
    });

    test('decodes a timed-out decision', () {
      expect(
        InAppContentBlockAvailabilityEncoder.decodeDecision(
            {'status': 'timedOut'}),
        const InAppContentBlockAvailabilityTimedOut(),
      );
    });

    test('unknown status collapses to timedOut', () {
      expect(
        InAppContentBlockAvailabilityEncoder.decodeDecision(
            {'status': 'pending'}),
        const InAppContentBlockAvailabilityTimedOut(),
      );
      expect(
        InAppContentBlockAvailabilityEncoder.decodeDecision({}),
        const InAppContentBlockAvailabilityTimedOut(),
      );
    });

    test('resolved without a terminal availability collapses to timedOut',
        () {
      expect(
        InAppContentBlockAvailabilityEncoder.decodeDecision({
          'status': 'resolved',
          'availability': 'loading',
        }),
        const InAppContentBlockAvailabilityTimedOut(),
      );
      expect(
        InAppContentBlockAvailabilityEncoder.decodeDecision({
          'status': 'resolved',
          'availability': 'parsing',
        }),
        const InAppContentBlockAvailabilityTimedOut(),
      );
    });
  });

  group('InAppContentBlockInvalidateModeEncoder', () {
    test('encodes modes as lowercase strings', () {
      expect(
          InAppContentBlockInvalidateModeEncoder.encode(
              InAppContentBlockInvalidateMode.eager),
          'eager');
      expect(
          InAppContentBlockInvalidateModeEncoder.encode(
              InAppContentBlockInvalidateMode.lazy),
          'lazy');
    });
  });
}
