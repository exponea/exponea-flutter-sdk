import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('IntegrationConfigurationChange', () {
    const encode = IntegrationConfigurationChangeEncoder.encode;
    const decode = IntegrationConfigurationChangeEncoder.decode;

    final data = readMapData('integration_configuration_change');
    test('check data', () async {
      expect(data.length, 4);
    });
    final emptyData = data[0];
    final streamData = data[1];
    final projectData = data[2];
    final fullData = data[3];

    group('encode', () {
      test('empty', () async {
        const change = IntegrationConfigurationChange();
        expect(encode(change), emptyData);
      });

      test('stream integration', () async {
        const change = IntegrationConfigurationChange(
          integrationConfig: StreamIntegrationConfig(streamId: 'mock-stream-id'),
        );
        expect(encode(change), streamData);
      });

      test('project integration', () async {
        const change = IntegrationConfigurationChange(
          integrationConfig: ProjectIntegrationConfig(
            projectToken: 'mock-project-token',
            authorizationToken: 'mock-auth-token',
          ),
        );
        expect(encode(change), projectData);
      });

      test('project with integrationRouteMap', () async {
        const change = IntegrationConfigurationChange(
          integrationConfig: ProjectIntegrationConfig(
            projectToken: 'mock-project-token',
            authorizationToken: 'mock-auth-token',
            baseUrl: 'https://api.exponea.com',
          ),
          integrationRouteMap: {
            EventType.payment: [
              ProjectIntegrationConfig(
                projectToken: 'other-project-token',
                authorizationToken: 'other-auth-token',
              ),
            ],
          },
        );
        expect(encode(change), fullData);
      });
    });

    group('decode', () {
      test('empty', () async {
        final decoded = decode(emptyData);

        expect(decoded.integrationConfig, isNull);
        expect(decoded.integrationRouteMap, isNull);
      });

      test('stream integration', () async {
        final decoded = decode(streamData);

        expect(decoded.integrationConfig, isA<StreamIntegrationConfig>());
        final stream = decoded.integrationConfig as StreamIntegrationConfig;
        expect(stream.streamId, 'mock-stream-id');
        expect(decoded.integrationRouteMap, isNull);
      });

      test('project integration', () async {
        final decoded = decode(projectData);

        expect(decoded.integrationConfig, isA<ProjectIntegrationConfig>());
        final project = decoded.integrationConfig as ProjectIntegrationConfig;
        expect(project.projectToken, 'mock-project-token');
        expect(project.authorizationToken, 'mock-auth-token');
        expect(decoded.integrationRouteMap, isNull);
      });

      test('project with integrationRouteMap', () async {
        final decoded = decode(fullData);

        expect(decoded.integrationConfig, isA<ProjectIntegrationConfig>());
        final project = decoded.integrationConfig as ProjectIntegrationConfig;
        expect(project.projectToken, 'mock-project-token');
        expect(project.authorizationToken, 'mock-auth-token');
        expect(project.baseUrl, 'https://api.exponea.com');
        expect(decoded.integrationRouteMap, isNotNull);
        final routes = decoded.integrationRouteMap![EventType.payment]!;
        expect(routes.length, 1);
        expect(routes.single.projectToken, 'other-project-token');
        expect(routes.single.authorizationToken, 'other-auth-token');
      });
    });
  });

  group('ConfigurationChange', () {
    const encode = ConfigurationChangeEncoder.encode;
    const decode = ConfigurationChangeEncoder.decode;

    test('ExponeaConfigurationChange is a ConfigurationChange subtype', () {
      const change = ExponeaConfigurationChange(
        project: ExponeaProject(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
        ),
      );
      expect(change, isA<ConfigurationChange>());
    });

    test('IntegrationConfigurationChange is a ConfigurationChange subtype', () {
      const change = IntegrationConfigurationChange(
        integrationConfig: StreamIntegrationConfig(streamId: 'mock-stream-id'),
      );
      expect(change, isA<ConfigurationChange>());
    });

    test('encode legacy ExponeaConfigurationChange unchanged', () {
      const change = ExponeaConfigurationChange(
        project: ExponeaProject(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
          baseUrl: 'http://mock.base.url.com',
        ),
      );

      expect(
        encode(change),
        ExponeaConfigurationChangeEncoder.encode(change),
      );
    });

    test('encode IntegrationConfigurationChange wire shape', () {
      const change = IntegrationConfigurationChange(
        integrationConfig: StreamIntegrationConfig(streamId: 'mock-stream-id'),
      );

      expect(
        encode(change),
        IntegrationConfigurationChangeEncoder.encode(change),
      );
    });

    test('decode legacy ExponeaConfigurationChange wire shape', () {
      final decoded = decode({
        'project': {
          'projectToken': 'mock-project-token',
          'authorizationToken': 'mock-auth-token',
        },
      });

      expect(decoded, isA<ExponeaConfigurationChange>());
      final change = decoded as ExponeaConfigurationChange;
      expect(change.project?.projectToken, 'mock-project-token');
    });

    test('decode IntegrationConfigurationChange wire shape', () {
      final decoded = decode({
        'integrationConfig': {'streamId': 'mock-stream-id'},
      });

      expect(decoded, isA<IntegrationConfigurationChange>());
      final change = decoded as IntegrationConfigurationChange;
      expect(change.integrationConfig, isA<StreamIntegrationConfig>());
    });

    test('rejects both integrationConfig and project', () {
      expect(
        () => decode({
          'integrationConfig': {'streamId': 'mock-stream-id'},
          'project': {
            'projectToken': 'mock-project-token',
            'authorizationToken': 'mock-auth-token',
          },
        }),
        throwsA(isA<StateError>()),
      );
    });
  });
}
