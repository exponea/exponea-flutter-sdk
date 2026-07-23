import 'dart:async';

import 'package:exponea/src/platform/method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelExponeaPlatform.flushData', () {
    const channel = MethodChannel('com.exponea');
    late MethodChannelExponeaPlatform platform;

    setUp(() {
      platform = MethodChannelExponeaPlatform();
    });

    tearDown(() {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });

    test('invokes the "flush" platform method', () async {
      final invocations = <MethodCall>[];
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (call) async {
        invocations.add(call);
        return null;
      });

      await platform.flushData();

      expect(invocations, hasLength(1));
      expect(invocations.single.method, equals('flush'));
      expect(invocations.single.arguments, isNull);
    });

    test('waits for the native handler to complete before resolving', () async {
      final nativeFlushComplete = Completer<void>();
      var nativeHandlerInvoked = false;

      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (call) async {
        nativeHandlerInvoked = true;
        await nativeFlushComplete.future;
        return null;
      });

      final flushFuture = platform.flushData();
      var flushResolved = false;
      unawaited(flushFuture.then((_) => flushResolved = true));

      await _waitFor(() => nativeHandlerInvoked,
          reason: 'platform handler should be invoked');
      expect(flushResolved, isFalse,
          reason:
              'flushData() must not resolve while the native handler is still pending');

      nativeFlushComplete.complete();
      await flushFuture;
      expect(flushResolved, isTrue);
    });

    test('propagates native handler errors as a PlatformException', () async {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (call) async {
        throw PlatformException(
          code: 'ExponeaPlugin',
          message: 'simulated native flush failure',
        );
      });

      await expectLater(
        platform.flushData(),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}

/// Polls [predicate] every microtask-tick until it returns true or [timeout]
/// elapses. Avoids a fixed sleep that can race on slow CI executors.
Future<void> _waitFor(
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 1),
  Duration interval = const Duration(milliseconds: 5),
  String? reason,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      fail(reason ?? 'condition was not met within $timeout');
    }
    await Future<void>.delayed(interval);
  }
}
