import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/util/sdk_setup_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    SdkSetupState.reset();
  });

  group('SdkSetupState — default state after reset', () {
    test('isCustomerIdentified is false', () {
      expect(SdkSetupState.isCustomerIdentified, isFalse);
    });

    test('registeredId is empty string', () {
      expect(SdkSetupState.registeredId, equals(''));
    });

    test('customerIds is empty map', () {
      expect(SdkSetupState.customerIds, isEmpty);
    });

    test('isStreamConfig is false', () {
      expect(SdkSetupState.isStreamConfig, isFalse);
    });
  });

  group('SdkSetupState.setCustomerIds', () {
    test('sets registeredId from the registered key', () {
      SdkSetupState.setCustomerIds({'registered': 'user@example.com'});
      expect(SdkSetupState.registeredId, equals('user@example.com'));
    });

    test('registeredId is empty when registered key absent', () {
      SdkSetupState.setCustomerIds({'email': 'user@example.com'});
      expect(SdkSetupState.registeredId, equals(''));
    });

    test('customerIds reflects all provided entries', () {
      final ids = {'registered': 'user@example.com', 'email': 'user@example.com'};
      SdkSetupState.setCustomerIds(ids);
      expect(SdkSetupState.customerIds, equals(ids));
    });

    test('customerIds is unmodifiable (does not expose internal map)', () {
      SdkSetupState.setCustomerIds({'registered': 'user@example.com'});
      expect(
        () => SdkSetupState.customerIds['new_key'] = 'value',
        throwsUnsupportedError,
      );
    });
  });

  group('SdkSetupState.isCustomerIdentified', () {
    test('persists true until reset', () {
      SdkSetupState.isCustomerIdentified = true;
      expect(SdkSetupState.isCustomerIdentified, isTrue);
    });
  });

  group('SdkSetupState.setStreamConfig', () {
    test('stream mode sets isStreamConfig to true', () {
      SdkSetupState.setStreamConfig(IntegrationMode.stream);
      expect(SdkSetupState.isStreamConfig, isTrue);
    });

    test('project mode sets isStreamConfig to false', () {
      SdkSetupState.setStreamConfig(IntegrationMode.stream);
      SdkSetupState.setStreamConfig(IntegrationMode.project);
      expect(SdkSetupState.isStreamConfig, isFalse);
    });
  });

  group('SdkSetupState.reset', () {
    test('clears isCustomerIdentified', () {
      SdkSetupState.isCustomerIdentified = true;
      SdkSetupState.reset();
      expect(SdkSetupState.isCustomerIdentified, isFalse);
    });

    test('clears customerIds and registeredId', () {
      SdkSetupState.setCustomerIds({'registered': 'user@example.com'});
      SdkSetupState.reset();
      expect(SdkSetupState.customerIds, isEmpty);
      expect(SdkSetupState.registeredId, equals(''));
    });

    test('clears isStreamConfig', () {
      SdkSetupState.setStreamConfig(IntegrationMode.stream);
      SdkSetupState.reset();
      expect(SdkSetupState.isStreamConfig, isFalse);
    });
  });
}
