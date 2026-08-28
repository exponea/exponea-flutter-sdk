import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/normalization/configure_payload.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('encodeConfigurePayload', () {
    final data = readMapData('configure_payload');
    test('check data', () {
      expect(data.length, 4);
    });
    final projectOnlyData = data[0];
    final streamWithIdentityData = data[1];
    final projectWithIdentityData = data[2];

    test('project config without customerIdentifier', () {
      const config = ExponeaConfiguration(
        integrationConfig: ProjectIntegrationConfig(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
        ),
      );

      expect(encodeConfigurePayload(config), projectOnlyData);
    });

    test('stream config with CustomerIdentity', () {
      const config = ExponeaConfiguration(
        integrationConfig: StreamIntegrationConfig(
          streamId: 'mock-stream-id',
          baseUrl: 'https://stream.exponea.com',
        ),
      );
      const identity = CustomerIdentity(
        customerIds: {'registered': 'test@mail.com'},
        sdkAuthToken: 'mock-jwt-token',
      );

      expect(
        encodeConfigurePayload(config, customerIdentifier: identity),
        streamWithIdentityData,
      );
    });

    test('legacy Customer uses customerIds only at configure time', () {
      const config = ExponeaConfiguration(
        integrationConfig: ProjectIntegrationConfig(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
        ),
      );
      const customer = Customer(
        ids: {'registered': 'test@mail.com'},
        properties: {'first_name': 'Alice'},
      );

      expect(
        encodeConfigurePayload(config, customerIdentifier: customer),
        projectWithIdentityData,
      );
    });

    test('omits customerIdentity key when not provided', () {
      const config = ExponeaConfiguration(
        integrationConfig: StreamIntegrationConfig(streamId: 'mock-stream-id'),
      );

      final payload = encodeConfigurePayload(config);
      expect(payload.containsKey('customerIdentity'), isFalse);
    });
  });
}
