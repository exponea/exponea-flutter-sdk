import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:exponea/src/data/normalization/configuration_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveIntegrationConfig', () {
    test('legacy flat fields produce ProjectIntegrationConfig', () {
      const config = ExponeaConfiguration(
        projectToken: 'mock-project-token',
        authorizationToken: 'mock-auth-token',
        baseUrl: 'https://api.exponea.com',
      );

      final resolved = resolveIntegrationConfig(config);

      expect(resolved, isA<ProjectIntegrationConfig>());
      final project = resolved as ProjectIntegrationConfig;
      expect(project.projectToken, 'mock-project-token');
      expect(project.authorizationToken, 'mock-auth-token');
      expect(project.baseUrl, 'https://api.exponea.com');
    });

    test('integrationConfig passes through unchanged', () {
      const integration = StreamIntegrationConfig(
        streamId: 'mock-stream-id',
        baseUrl: 'https://stream.exponea.com',
      );
      const config = ExponeaConfiguration(integrationConfig: integration);

      expect(resolveIntegrationConfig(config), integration);
    });

    test('rejects both integrationConfig and legacy flat fields', () {
      const config = ExponeaConfiguration(
        integrationConfig: ProjectIntegrationConfig(
          projectToken: 'new-token',
          authorizationToken: 'Token new-auth',
        ),
        projectToken: 'legacy-token',
        authorizationToken: 'Token legacy-auth',
      );

      expect(
        () => resolveIntegrationConfig(config),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects missing authorization token in legacy decode path', () {
      expect(
        () => ExponeaConfigurationEncoder.decode({'projectToken': 'only-token'}),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('resolveIntegrationRouteMap', () {
    test('projectMapping normalizes to integrationRouteMap', () {
      const config = ExponeaConfiguration(
        projectToken: 'mock-project-token',
        authorizationToken: 'mock-auth-token',
        projectMapping: {
          EventType.banner: [
            ExponeaProject(
              projectToken: 'other-project-token',
              authorizationToken: 'other-auth-token',
            ),
          ],
        },
      );
      const integration = ProjectIntegrationConfig(
        projectToken: 'mock-project-token',
        authorizationToken: 'mock-auth-token',
      );

      final routeMap = resolveIntegrationRouteMap(config, integration);

      expect(routeMap, isNotNull);
      expect(routeMap!.length, 1);
      final routes = routeMap[EventType.banner]!;
      expect(routes.length, 1);
      expect(routes.single.projectToken, 'other-project-token');
      expect(routes.single.authorizationToken, 'other-auth-token');
    });

    test('integrationRouteMap passes through for project mode', () {
      const routeEntry = ProjectIntegrationConfig(
        projectToken: 'analytics-token',
        authorizationToken: 'Token abc',
      );
      const config = ExponeaConfiguration(
        integrationConfig: ProjectIntegrationConfig(
          projectToken: 'mock-project-token',
          authorizationToken: 'mock-auth-token',
        ),
        integrationRouteMap: {
          EventType.trackEvent: [routeEntry],
        },
      );
      const integration = ProjectIntegrationConfig(
        projectToken: 'mock-project-token',
        authorizationToken: 'mock-auth-token',
      );

      final routeMap = resolveIntegrationRouteMap(config, integration);

      expect(routeMap, config.integrationRouteMap);
    });

    test('stream mode omits route map when projectMapping is set', () {
      const config = ExponeaConfiguration(
        integrationConfig: StreamIntegrationConfig(streamId: 'mock-stream-id'),
        projectMapping: {
          EventType.banner: [
            ExponeaProject(
              projectToken: 'other-project-token',
              authorizationToken: 'other-auth-token',
            ),
          ],
        },
      );

      final routeMap = resolveIntegrationRouteMap(
        config,
        config.integrationConfig!,
      );

      expect(routeMap, isNull);
    });
  });

  group('ExponeaConfigurationEncoder.encode', () {
    test('legacy flat fields encode as integrationConfig map', () {
      const config = ExponeaConfiguration(
        projectToken: 'mock-project-token',
        authorizationToken: 'mock-auth-token',
      );

      final encoded = ExponeaConfigurationEncoder.encode(config);

      expect(encoded['projectToken'], isNull);
      expect(encoded['authorizationToken'], isNull);
      expect(
        encoded['integrationConfig'],
        IntegrationConfigEncoder.encode(
          const ProjectIntegrationConfig(
            projectToken: 'mock-project-token',
            authorizationToken: 'mock-auth-token',
          ),
        ),
      );
    });

    test('stream config omits advancedAuthEnabled and integrationRouteMap', () {
      const config = ExponeaConfiguration(
        integrationConfig: StreamIntegrationConfig(streamId: 'mock-stream-id'),
        advancedAuthEnabled: true,
        integrationRouteMap: {
          EventType.banner: [
            ProjectIntegrationConfig(
              projectToken: 'other-project-token',
              authorizationToken: 'other-auth-token',
            ),
          ],
        },
      );

      final encoded = ExponeaConfigurationEncoder.encode(config);

      expect(encoded.containsKey('advancedAuthEnabled'), isFalse);
      expect(encoded.containsKey('integrationRouteMap'), isFalse);
      expect(encoded.containsKey('projectMapping'), isFalse);
      expect(
        encoded['integrationConfig'],
        IntegrationConfigEncoder.encode(
          const StreamIntegrationConfig(streamId: 'mock-stream-id'),
        ),
      );
    });
  });
}
