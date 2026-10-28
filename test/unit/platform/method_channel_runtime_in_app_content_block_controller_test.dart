import 'package:exponea/exponea.dart';
import 'package:exponea/src/platform/method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.exponea');

  late MethodChannelExponeaPlatform platform;
  late List<MethodCall> invocations;

  void mockNative(Object? Function(MethodCall call) handler) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      invocations.add(call);
      return handler(call);
    });
  }

  setUp(() {
    platform = MethodChannelExponeaPlatform();
    invocations = [];
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('inAppContentBlocksControllerPrefetch', () {
    test('sends ids and deadlineMs and decodes the result', () async {
      mockNative((_) => {'a': 'ready', 'b': 'empty'});

      final result =
          await platform.inAppContentBlocksControllerPrefetch(['a', 'b'], 2000);

      expect(invocations.single.method, 'inAppContentBlocksControllerPrefetch');
      expect(invocations.single.arguments, {
        'ids': ['a', 'b'],
        'deadlineMs': 2000,
      });
      expect(result, {
        'a': InAppContentBlockAvailability.ready,
        'b': InAppContentBlockAvailability.empty,
      });
    });

    test('sends a null deadline when none is given', () async {
      mockNative((_) => {'a': 'loading'});

      await platform.inAppContentBlocksControllerPrefetch(['a'], null);

      expect(invocations.single.arguments, {
        'ids': ['a'],
        'deadlineMs': null,
      });
    });

    test('passes a zero or negative deadline unchanged', () async {
      mockNative((_) => {'a': 'loading'});

      await platform.inAppContentBlocksControllerPrefetch(['a'], 0);
      await platform.inAppContentBlocksControllerPrefetch(['a'], -5);

      expect(invocations.map((it) => it.arguments['deadlineMs']), [0, -5]);
    });

    test('unknown native state collapses to loading', () async {
      mockNative((_) => {'a': 'parsing'});

      final result =
          await platform.inAppContentBlocksControllerPrefetch(['a'], 2000);

      expect(result, {'a': InAppContentBlockAvailability.loading});
    });
  });

  group('inAppContentBlocksControllerAvailability', () {
    test('sends id and deadlineMs and decodes resolved', () async {
      mockNative((_) => {'status': 'resolved', 'availability': 'ready'});

      final result =
          await platform.inAppContentBlocksControllerAvailability('a', 2000);

      expect(invocations.single.method,
          'inAppContentBlocksControllerAvailability');
      expect(invocations.single.arguments, {'id': 'a', 'deadlineMs': 2000});
      expect(
        result,
        const InAppContentBlockAvailabilityResolved(
            InAppContentBlockAvailability.ready),
      );
    });

    test('decodes timedOut', () async {
      mockNative((_) => {'status': 'timedOut'});

      final result =
          await platform.inAppContentBlocksControllerAvailability('a', 2000);

      expect(result, const InAppContentBlockAvailabilityTimedOut());
    });

    test('passes a zero or negative deadline unchanged', () async {
      mockNative((_) => {'status': 'timedOut'});

      await platform.inAppContentBlocksControllerAvailability('a', 0);
      await platform.inAppContentBlocksControllerAvailability('a', -1);

      expect(invocations.map((it) => it.arguments['deadlineMs']), [0, -1]);
    });

    test('unknown native status collapses to timedOut', () async {
      mockNative((_) => {'status': 'pending'});

      final result =
          await platform.inAppContentBlocksControllerAvailability('a', 2000);

      expect(result, const InAppContentBlockAvailabilityTimedOut());
    });
  });

  group('inAppContentBlocksControllerInvalidate', () {
    test('sends ids, reason and the lowercase mode', () async {
      mockNative((_) => null);

      await platform.inAppContentBlocksControllerInvalidate(
          ['a'], 'x', InAppContentBlockInvalidateMode.eager);
      await platform.inAppContentBlocksControllerInvalidate(
          ['b'], 'y', InAppContentBlockInvalidateMode.lazy);

      expect(invocations.map((it) => it.method), [
        'inAppContentBlocksControllerInvalidate',
        'inAppContentBlocksControllerInvalidate',
      ]);
      expect(invocations[0].arguments, {
        'ids': ['a'],
        'reason': 'x',
        'mode': 'eager',
      });
      expect(invocations[1].arguments, {
        'ids': ['b'],
        'reason': 'y',
        'mode': 'lazy',
      });
    });
  });

  group('native errors', () {
    test('PlatformException codes from native are passed through',
        () async {
      for (final code in [
        'RuntimeInAppContentBlockControllerUnavailable',
        'RuntimeInAppContentBlockControllerInvalidMode',
        'RuntimeInAppContentBlockControllerError',
      ]) {
        mockNative((_) => throw PlatformException(code: code, message: 'm'));

        await expectLater(
          platform.inAppContentBlocksControllerPrefetch(['a'], 1),
          throwsA(isA<PlatformException>()
              .having((e) => e.code, 'code', code)
              .having((e) => e.message, 'message', 'm')),
        );
        await expectLater(
          platform.inAppContentBlocksControllerAvailability('a', 1),
          throwsA(isA<PlatformException>().having((e) => e.code, 'code', code)),
        );
        await expectLater(
          platform.inAppContentBlocksControllerInvalidate(
              ['a'], 'x', InAppContentBlockInvalidateMode.eager),
          throwsA(isA<PlatformException>().having((e) => e.code, 'code', code)),
        );
      }
    });
  });
}
