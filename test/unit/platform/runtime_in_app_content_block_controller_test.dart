import 'dart:async';

import 'package:exponea/exponea.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _unavailable = 'RuntimeInAppContentBlockControllerUnavailable';

class _FakePlatform extends ExponeaPlatform {
  bool configureResult = true;
  bool isConfiguredResult = false;
  Completer<bool>? isConfiguredCompleter;
  Object? isConfiguredError;
  Object? stopIntegrationError;
  int isConfiguredCalls = 0;
  final List<String> controllerCalls = [];
  final List<List<Object?>> controllerArgs = [];

  @override
  Future<bool> configure(
    ExponeaConfiguration configuration, {
    CustomerIdentifier? customerIdentifier,
  }) async =>
      configureResult;

  @override
  Future<bool> isConfigured() {
    isConfiguredCalls++;
    final error = isConfiguredError;
    if (error != null) {
      isConfiguredError = null;
      return Future.error(error);
    }
    return isConfiguredCompleter?.future ?? Future.value(isConfiguredResult);
  }

  @override
  Future<void> stopIntegration() async {
    final error = stopIntegrationError;
    if (error != null) throw error;
  }

  @override
  Future<void> identifyCustomer(
    CustomerIdentifier identifier, {
    Map<String, dynamic>? properties,
  }) async {}

  @override
  Future<void> anonymize([
    ConfigurationChange configurationChange =
        const ExponeaConfigurationChange(),
  ]) async {}

  @override
  Future<Map<String, InAppContentBlockAvailability>>
      inAppContentBlocksControllerPrefetch(
    List<String> ids,
    int? deadlineMs,
  ) async {
    controllerCalls.add('prefetch');
    controllerArgs.add([ids, deadlineMs]);
    return {for (final id in ids) id: InAppContentBlockAvailability.ready};
  }

  @override
  Future<InAppContentBlockAvailabilityDecision>
      inAppContentBlocksControllerAvailability(
    String id,
    int deadlineMs,
  ) async {
    controllerCalls.add('availability');
    controllerArgs.add([id, deadlineMs]);
    return const InAppContentBlockAvailabilityTimedOut();
  }

  @override
  Future<void> inAppContentBlocksControllerInvalidate(
    List<String> ids,
    String reason,
    InAppContentBlockInvalidateMode mode,
  ) async {
    controllerCalls.add('invalidate');
    controllerArgs.add([ids, reason, mode]);
  }
}

const _config = ExponeaConfiguration(
  projectToken: 'mock-token',
  authorizationToken: 'mock-auth',
);

Matcher _throwsUnavailable() => throwsA(isA<PlatformException>()
    .having((e) => e.code, 'code', _unavailable)
    .having((e) => e.message, 'message',
        contains('ExponeaPlugin().inAppContentBlocksController')));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakePlatform platform;

  setUp(() {
    platform = _FakePlatform();
    ExponeaPlatform.instance = platform;
  });

  group('getter lifecycle', () {
    test('null before configure', () async {
      final plugin = ExponeaPlugin();
      await pumpEventQueue();

      expect(plugin.inAppContentBlocksController, isNull);
    });

    test('instance after configure() returns true', () async {
      final plugin = ExponeaPlugin();

      expect(await plugin.configure(_config), isTrue);

      expect(plugin.inAppContentBlocksController, isNotNull);
    });

    test('state is shared across ExponeaPlugin instances', () async {
      await ExponeaPlugin().configure(_config);

      expect(
        ExponeaPlugin().inAppContentBlocksController,
        same(ExponeaPlugin().inAppContentBlocksController),
      );
      expect(ExponeaPlugin().inAppContentBlocksController, isNotNull);
    });

    test(
        'configure() returning false keeps the instance and the held '
        'reference keeps working', () async {
      final plugin = ExponeaPlugin();
      await plugin.configure(_config);
      final held = plugin.inAppContentBlocksController!;

      platform.configureResult = false;
      expect(await plugin.configure(_config), isFalse);

      expect(plugin.inAppContentBlocksController, same(held));
      await held.prefetch(['a']);
      expect(platform.controllerCalls, ['prefetch']);
    });

    test('configure() returning false creates an instance when null',
        () async {
      platform.configureResult = false;
      final plugin = ExponeaPlugin();

      await plugin.configure(_config);

      expect(plugin.inAppContentBlocksController, isNotNull);
    });

    test(
        'configure() returning true replaces the instance and deactivates '
        'the old one', () async {
      final plugin = ExponeaPlugin();
      await plugin.configure(_config);
      final old = plugin.inAppContentBlocksController!;

      await plugin.configure(_config);

      expect(plugin.inAppContentBlocksController, isNotNull);
      expect(plugin.inAppContentBlocksController, isNot(same(old)));
      await expectLater(old.prefetch(['a']), _throwsUnavailable());
    });

    test('identifyCustomer() and anonymize() keep the same instance',
        () async {
      final plugin = ExponeaPlugin();
      await plugin.configure(_config);
      final held = plugin.inAppContentBlocksController;

      await plugin
          .identifyCustomer(const Customer(ids: {'registered': 'user_a'}));
      expect(plugin.inAppContentBlocksController, same(held));

      await plugin.anonymize();
      expect(plugin.inAppContentBlocksController, same(held));
    });

    test('isConfigured() seed makes the getter non-null', () async {
      platform.isConfiguredCompleter = Completer<bool>();
      final plugin = ExponeaPlugin();

      expect(plugin.inAppContentBlocksController, isNull);

      platform.isConfiguredCompleter!.complete(true);
      await pumpEventQueue();

      expect(plugin.inAppContentBlocksController, isNotNull);
    });

    test('the seed runs once per platform', () async {
      ExponeaPlugin();
      ExponeaPlugin();
      await pumpEventQueue();
      ExponeaPlugin().inAppContentBlocksController;

      expect(platform.isConfiguredCalls, 1);
    });

    test('a failed seed is retried by the next ExponeaPlugin()', () async {
      platform.isConfiguredError = MissingPluginException();
      final plugin = ExponeaPlugin();
      await pumpEventQueue();
      expect(plugin.inAppContentBlocksController, isNull);

      platform.isConfiguredResult = true;
      ExponeaPlugin();
      await pumpEventQueue();

      expect(plugin.inAppContentBlocksController, isNotNull);
      expect(platform.isConfiguredCalls, 2);
    });

    test('a late seed does not replace an instance created by configure()',
        () async {
      platform.isConfiguredCompleter = Completer<bool>();
      final plugin = ExponeaPlugin();
      await plugin.configure(_config);
      final created = plugin.inAppContentBlocksController;

      platform.isConfiguredCompleter!.complete(true);
      await pumpEventQueue();

      expect(plugin.inAppContentBlocksController, same(created));
    });

    test('a late seed does not revive the getter after stopIntegration()',
        () async {
      platform.isConfiguredCompleter = Completer<bool>();
      final plugin = ExponeaPlugin();
      await plugin.configure(_config);
      await plugin.stopIntegration();

      platform.isConfiguredCompleter!.complete(true);
      await pumpEventQueue();

      expect(plugin.inAppContentBlocksController, isNull);
    });

    test(
        'stopIntegration() clears the getter and the old instance throws '
        'Unavailable without calling native', () async {
      final plugin = ExponeaPlugin();
      await plugin.configure(_config);
      final held = plugin.inAppContentBlocksController!;

      await plugin.stopIntegration();

      expect(plugin.inAppContentBlocksController, isNull);
      await expectLater(held.prefetch(['a'], 100), _throwsUnavailable());
      await expectLater(held.availability('a', 100), _throwsUnavailable());
      await expectLater(held.invalidate(['a'], 'x'), _throwsUnavailable());
      expect(platform.controllerCalls, isEmpty);
    });

    test('a deactivated instance stays unusable after a new configure()',
        () async {
      final plugin = ExponeaPlugin();
      await plugin.configure(_config);
      final held = plugin.inAppContentBlocksController!;
      await plugin.stopIntegration();

      await plugin.configure(_config);

      expect(plugin.inAppContentBlocksController, isNotNull);
      expect(plugin.inAppContentBlocksController, isNot(same(held)));
      await expectLater(held.prefetch(['a']), _throwsUnavailable());
    });

    test('a failed stopIntegration() keeps the instance', () async {
      final plugin = ExponeaPlugin();
      await plugin.configure(_config);
      final held = plugin.inAppContentBlocksController;
      platform.stopIntegrationError = PlatformException(code: 'ExponeaPlugin');

      await expectLater(plugin.stopIntegration(), throwsA(isA<PlatformException>()));

      expect(plugin.inAppContentBlocksController, same(held));
    });
  });

  group('controller delegation', () {
    late RuntimeInAppContentBlockController controller;

    setUp(() async {
      final plugin = ExponeaPlugin();
      await plugin.configure(_config);
      controller = plugin.inAppContentBlocksController!;
    });

    test('prefetch forwards ids and deadline', () async {
      final result = await controller.prefetch(['a', 'b'], 2000);

      expect(platform.controllerCalls, ['prefetch']);
      expect(platform.controllerArgs.single, [
        ['a', 'b'],
        2000,
      ]);
      expect(result, {
        'a': InAppContentBlockAvailability.ready,
        'b': InAppContentBlockAvailability.ready,
      });
    });

    test('prefetch without a deadline forwards null', () async {
      await controller.prefetch(['a']);

      expect(platform.controllerArgs.single, [
        ['a'],
        null,
      ]);
    });

    test('availability forwards id and deadline', () async {
      final result = await controller.availability('a', 2000);

      expect(platform.controllerArgs.single, ['a', 2000]);
      expect(result, const InAppContentBlockAvailabilityTimedOut());
    });

    test('invalidate defaults to eager', () async {
      await controller.invalidate(['a'], 'x');
      await controller.invalidate(
          ['b'], 'y', InAppContentBlockInvalidateMode.lazy);

      expect(platform.controllerArgs, [
        [
          ['a'],
          'x',
          InAppContentBlockInvalidateMode.eager,
        ],
        [
          ['b'],
          'y',
          InAppContentBlockInvalidateMode.lazy,
        ],
      ]);
    });
  });
}
