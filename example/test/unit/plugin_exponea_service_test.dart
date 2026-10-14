import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/services/plugin_exponea_service.dart';
import 'package:exponea_example/services/sdk_status_store.dart';
import 'package:exponea/exponea.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<ExponeaPlatform>(mixingIn: [MockPlatformInterfaceMixin]),
])
import 'plugin_exponea_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockExponeaPlatform mockPlatform;
  late PluginExponeaService service;

  setUp(() {
    mockPlatform = MockExponeaPlatform();
    ExponeaPlatform.instance = mockPlatform;
    service = PluginExponeaService();
  });

  group('PluginExponeaService.configure — project mode', () {
    const minimalProjectRequest = ConfigureRequest(
      mode: IntegrationMode.project,
      baseUrl: 'https://api.exponea.com',
      projectToken: 'test-token',
      authorizationToken: 'test-auth',
    );

    test('configure succeeds: isConfigured becomes true', () async {
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenAnswer((_) async => true);

      await service.configure(minimalProjectRequest);

      expect(service.isConfigured, isTrue);
    });

    test('configure without customerId: statusStore is anonymous', () async {
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenAnswer((_) async => true);

      await service.configure(minimalProjectRequest);

      expect(service.statusStore.state, equals(SdkLifecycleState.anonymous));
    });

    test('configure with customerId: statusStore is identified', () async {
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenAnswer((_) async => true);

      await service.configure(
        const ConfigureRequest(
          mode: IntegrationMode.project,
          baseUrl: 'https://api.exponea.com',
          projectToken: 'test-token',
          authorizationToken: 'test-auth',
          customerId: 'user@example.com',
        ),
      );

      expect(service.statusStore.state, equals(SdkLifecycleState.identified));
    });

    test('configure appends log entry on success', () async {
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenAnswer((_) async => true);

      await service.configure(minimalProjectRequest);

      expect(service.logs.any((line) => line.contains('SDK configured')), isTrue);
    });

    test('configure failure: statusStore stays notInitialized and rethrows', () async {
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenThrow(PlatformException(code: 'ERR', message: 'init failed'));

      await expectLater(
        () => service.configure(minimalProjectRequest),
        throwsA(isA<PlatformException>()),
      );

      expect(service.isConfigured, isFalse);
      expect(service.statusStore.state, equals(SdkLifecycleState.notInitialized));
    });
  });

  group('PluginExponeaService.stopIntegration', () {
    test('stopIntegration: isConfigured becomes false and statusStore is notInitialized', () async {
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenAnswer((_) async => true);
      await service.configure(
        const ConfigureRequest(
          mode: IntegrationMode.project,
          baseUrl: 'https://api.exponea.com',
          projectToken: 'test-token',
          authorizationToken: 'test-auth',
        ),
      );
      expect(service.isConfigured, isTrue);

      await service.stopIntegration();

      expect(service.isConfigured, isFalse);
      expect(service.statusStore.state, equals(SdkLifecycleState.notInitialized));
    });

    test('stopIntegration resets state even when native throws', () async {
      when(mockPlatform.stopIntegration())
          .thenThrow(PlatformException(code: 'ERR', message: 'not configured'));

      await service.stopIntegration();

      expect(service.isConfigured, isFalse);
      expect(service.statusStore.state, equals(SdkLifecycleState.notInitialized));
    });
  });

  group('PluginExponeaService.anonymize', () {
    test('anonymize: statusStore transitions to anonymous', () async {
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenAnswer((_) async => true);
      await service.configure(
        const ConfigureRequest(
          mode: IntegrationMode.project,
          baseUrl: 'https://api.exponea.com',
          projectToken: 'test-token',
          authorizationToken: 'test-auth',
          customerId: 'user@example.com',
        ),
      );
      expect(service.statusStore.state, equals(SdkLifecycleState.identified));

      await service.anonymize();

      expect(service.statusStore.state, equals(SdkLifecycleState.anonymous));
    });

    test('anonymize appends log entry', () async {
      await service.anonymize();

      expect(service.logs.any((line) => line.contains('anonymized')), isTrue);
    });
  });

  group('PluginExponeaService.clearLocalCustomerData', () {
    test('clearLocalCustomerData: statusStore transitions to anonymous', () async {
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenAnswer((_) async => true);
      await service.configure(
        const ConfigureRequest(
          mode: IntegrationMode.project,
          baseUrl: 'https://api.exponea.com',
          projectToken: 'test-token',
          authorizationToken: 'test-auth',
          customerId: 'user@example.com',
        ),
      );

      await service.clearLocalCustomerData();

      expect(service.statusStore.state, equals(SdkLifecycleState.anonymous));
    });

    test('clearLocalCustomerData appends log entry', () async {
      await service.clearLocalCustomerData();

      expect(service.logs.any((line) => line.contains('cleared')), isTrue);
    });
  });

  group('PluginExponeaService listeners', () {
    const request = ConfigureRequest(
      mode: IntegrationMode.project,
      baseUrl: 'https://api.exponea.com',
      projectToken: 'test-token',
      authorizationToken: 'test-auth',
    );

    late Map<String, StreamController<List<Map<String, String>>>> segments;
    late StreamController<InAppMessageAction> inApp;
    late StreamController<ReceivedPush> received;
    late StreamController<OpenedPush> opened;

    setUp(() {
      segments = {
        for (final category in segmentationListenerCategories)
          category: StreamController<List<Map<String, String>>>.broadcast(),
      };
      inApp = StreamController<InAppMessageAction>.broadcast();
      received = StreamController<ReceivedPush>.broadcast();
      opened = StreamController<OpenedPush>.broadcast();
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenAnswer((_) async => true);
      when(mockPlatform.segmentationDataStream(any, includeFirstLoad: anyNamed('includeFirstLoad')))
          .thenAnswer((invocation) async =>
              segments[invocation.positionalArguments.first as String]!.stream);
      when(mockPlatform.inAppMessageActionStream(
        overrideDefaultBehavior: anyNamed('overrideDefaultBehavior'),
        trackActions: anyNamed('trackActions'),
      )).thenAnswer((_) => inApp.stream);
      when(mockPlatform.receivedPushStream).thenAnswer((_) => received.stream);
      when(mockPlatform.openedPushStream).thenAnswer((_) => opened.stream);
    });

    Future<void> pump() => Future<void>.delayed(Duration.zero);

    test('logs segmentation, in-app and push events after configure', () async {
      await service.configure(request);

      segments['content']!.add([
        {'id': 'seg-1'},
      ]);
      inApp.add(const InAppMessageAction(
        type: InAppMessageActionType.click,
        message: InAppMessage(
          id: 'm1',
          name: 'Promo',
          frequency: 'always',
          variantId: 0,
          variantName: 'A',
        ),
        button: InAppMessageButton(text: 'Open', url: 'exponea://promo'),
      ));
      received.add(const ReceivedPush(data: {'campaign': 'c1'}));
      opened.add(const OpenedPush(action: PushActionType.app));
      await pump();

      expect(service.logs, contains('Segmentation: new data for content: [{id: seg-1}]'));
      expect(service.logs, contains('InAppMessage: click Promo, Open, exponea://promo'));
      expect(service.logs, contains('Push: received {campaign: c1}'));
      expect(service.logs, contains('Push: opened app'));
    });

    test('in-app actions are observed without overriding SDK behaviour', () async {
      await service.configure(request);

      verify(mockPlatform.inAppMessageActionStream(
        overrideDefaultBehavior: false,
        trackActions: true,
      )).called(1);
      for (final category in segmentationListenerCategories) {
        verify(mockPlatform.segmentationDataStream(category, includeFirstLoad: false))
            .called(1);
      }
    });

    test('stopIntegration cancels listeners', () async {
      await service.configure(request);
      await service.stopIntegration();
      await pump();

      expect(inApp.hasListener, isFalse);
      expect(received.hasListener, isFalse);
      expect(opened.hasListener, isFalse);
      expect(segments.values.any((c) => c.hasListener), isFalse);
    });

    test('re-configure does not log events twice', () async {
      await service.configure(request);
      await service.configure(request);

      opened.add(const OpenedPush(action: PushActionType.app));
      await pump();

      expect(service.logs.where((line) => line == 'Push: opened app'), hasLength(1));
    });

    test('a failing listener does not break configure', () async {
      when(mockPlatform.openedPushStream).thenThrow(UnimplementedError());

      await service.configure(request);

      expect(service.isConfigured, isTrue);
      expect(service.logs.any((line) => line.startsWith('Push listener failed')), isTrue);
    });
  });

  group('PluginExponeaService customer token IDs', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      when(mockPlatform.configure(any, customerIdentifier: anyNamed('customerIdentifier')))
          .thenAnswer((_) async => true);
    });

    Future<String?> storedIds() async =>
        (await SharedPreferences.getInstance()).getString('customer_ids');

    test('configure with customer ID stores it for the native provider', () async {
      await service.configure(const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.exponea.com',
        projectToken: 'test-token',
        authorizationToken: 'test-auth',
        customerId: 'jane@example.com',
      ));

      expect(await storedIds(), '{"registered":"jane@example.com"}');
    });

    test('identify replaces and anonymize clears the stored IDs', () async {
      await service.configure(const ConfigureRequest(
        mode: IntegrationMode.project,
        baseUrl: 'https://api.exponea.com',
        projectToken: 'test-token',
        authorizationToken: 'test-auth',
      ));
      await service.identifyCustomer(customerIds: {'registered': 'joe@example.com'});
      expect(await storedIds(), '{"registered":"joe@example.com"}');

      await service.anonymize();
      expect(await storedIds(), isNull);
    });
  });
}
