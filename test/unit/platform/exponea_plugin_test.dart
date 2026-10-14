import 'package:exponea/exponea.dart';
import 'package:exponea/src/platform/platform_interface.dart';
import 'package:exponea/src/plugin/exponea.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// MockPlatformInterfaceMixin is required so verifyToken() in
// PlatformInterface accepts the mock as a valid platform instance.
@GenerateNiceMocks([
  MockSpec<ExponeaPlatform>(mixingIn: [MockPlatformInterfaceMixin]),
])
import 'exponea_plugin_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockExponeaPlatform mockPlatform;
  late ExponeaPlugin plugin;

  setUp(() {
    mockPlatform = MockExponeaPlatform();
    ExponeaPlatform.instance = mockPlatform;
    plugin = ExponeaPlugin();
  });

  group('ExponeaPlugin.configure', () {
    const config = ExponeaConfiguration(
      projectToken: 'mock-token',
      authorizationToken: 'mock-auth',
    );

    test('delegates to platform and returns true on first call', () async {
      when(mockPlatform.configure(config)).thenAnswer((_) async => true);

      final result = await plugin.configure(config);

      expect(result, isTrue);
      verify(mockPlatform.configure(config)).called(1);
    });

    test('delegates to platform and returns false when already configured',
        () async {
      when(mockPlatform.configure(config)).thenAnswer((_) async => false);

      final result = await plugin.configure(config);

      expect(result, isFalse);
      verify(mockPlatform.configure(config)).called(1);
    });
  });

  group('ExponeaPlugin.anonymize', () {
    test('delegates with default ConfigurationChange', () async {
      when(mockPlatform.anonymize()).thenAnswer((_) async {});

      await plugin.anonymize();

      verify(mockPlatform.anonymize()).called(1);
    });

    test('delegates with explicit ConfigurationChange', () async {
      const change = ExponeaConfigurationChange(
        project: ExponeaProject(
          projectToken: 'new-token',
          authorizationToken: 'new-auth',
        ),
      );
      when(mockPlatform.anonymize(change)).thenAnswer((_) async {});

      await plugin.anonymize(change);

      verify(mockPlatform.anonymize(change)).called(1);
    });
  });

  group('ExponeaPlugin.fetchConsents', () {
    test('delegates and returns platform result', () async {
      final consents = [
        const Consent(
          id: 'mock-consent',
          legitimateInterest: false,
          sources: ConsentSources(
            createdFromCRM: false,
            imported: false,
            fromConsentPage: false,
            privateAPI: false,
            publicAPI: false,
            trackedFromScenario: false,
          ),
          translations: {},
        ),
      ];
      when(mockPlatform.fetchConsents()).thenAnswer((_) async => consents);

      final result = await plugin.fetchConsents();

      expect(result, equals(consents));
      verify(mockPlatform.fetchConsents()).called(1);
    });
  });

  group('ExponeaPlugin.getCustomerCookie', () {
    test('delegates and returns cookie string', () async {
      when(mockPlatform.getCustomerCookie())
          .thenAnswer((_) async => 'mock-cookie-123');

      final result = await plugin.getCustomerCookie();

      expect(result, equals('mock-cookie-123'));
      verify(mockPlatform.getCustomerCookie()).called(1);
    });
  });
}
