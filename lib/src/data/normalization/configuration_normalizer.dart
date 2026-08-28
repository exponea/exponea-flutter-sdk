import 'dart:developer' as developer;

import '../encoder/event_type.dart';
import '../encoder/integration_config.dart';
import '../model/configuration.dart';
import '../model/event_type.dart';
import '../model/integration_config.dart';

const _logName = 'exponea';

IntegrationConfig resolveIntegrationConfig(ExponeaConfiguration config) {
  final hasLegacyFields = _hasLegacyIntegrationFields(config);

  if (config.integrationConfig != null) {
    if (hasLegacyFields) {
      throw ArgumentError(
        'ExponeaConfiguration cannot set both integrationConfig and legacy '
        'projectToken, authorizationToken, or baseUrl.',
      );
    }
    return config.integrationConfig!;
  }

  final projectToken = config.projectToken;
  final authorizationToken = config.authorizationToken;
  if (projectToken == null || authorizationToken == null) {
    throw ArgumentError(
      'ExponeaConfiguration requires integrationConfig or legacy '
      'projectToken and authorizationToken.',
    );
  }

  developer.log(
    'ExponeaConfiguration projectToken, authorizationToken, and baseUrl are '
    'deprecated. Use integrationConfig with ProjectIntegrationConfig instead.',
    name: _logName,
  );

  return ProjectIntegrationConfig(
    projectToken: projectToken,
    authorizationToken: authorizationToken,
    baseUrl: config.baseUrl,
  );
}

Map<EventType, List<ProjectIntegrationConfig>>? resolveIntegrationRouteMap(
  ExponeaConfiguration config,
  IntegrationConfig integrationConfig,
) {
  if (integrationConfig is StreamIntegrationConfig) {
    if (_hasRouteMapFields(config)) {
      developer.log(
        'integrationRouteMap and projectMapping are ignored for Stream '
        'integrationConfig.',
        name: _logName,
      );
    }
    return null;
  }

  if (config.integrationRouteMap != null && config.projectMapping != null) {
    throw ArgumentError(
      'ExponeaConfiguration cannot set both integrationRouteMap and '
      'projectMapping.',
    );
  }

  if (config.integrationRouteMap != null) {
    return config.integrationRouteMap;
  }

  final projectMapping = config.projectMapping;
  if (projectMapping == null) {
    return null;
  }

  developer.log(
    'ExponeaConfiguration projectMapping is deprecated. Use '
    'integrationRouteMap with ProjectIntegrationConfig entries instead.',
    name: _logName,
  );

  return projectMapping.map(
    (eventType, projects) => MapEntry(
      eventType,
      projects
          .map(
            (project) => ProjectIntegrationConfig(
              projectToken: project.projectToken,
              authorizationToken: project.authorizationToken,
              baseUrl: project.baseUrl,
            ),
          )
          .toList(growable: false),
    ),
  );
}

bool shouldOmitAdvancedAuthForStream(ExponeaConfiguration config) {
  final integrationConfig = config.integrationConfig;
  if (integrationConfig is StreamIntegrationConfig &&
      config.advancedAuthEnabled == true) {
    developer.log(
      'advancedAuthEnabled is ignored for Stream integrationConfig.',
      name: _logName,
    );
    return true;
  }
  return integrationConfig is StreamIntegrationConfig;
}

bool _hasLegacyIntegrationFields(ExponeaConfiguration config) {
  return config.projectToken != null ||
      config.authorizationToken != null ||
      config.baseUrl != null;
}

bool _hasRouteMapFields(ExponeaConfiguration config) {
  return config.integrationRouteMap != null || config.projectMapping != null;
}

abstract class IntegrationRouteMapEncoder {
  static Map<EventType, List<ProjectIntegrationConfig>> decode(
    Map<String, dynamic> data,
  ) {
    return data.map(
      (key, value) => MapEntry(
        EventTypeEncoder.decode(key),
        value
            .map((project) {
              final integration = IntegrationConfigEncoder.decode(project);
              if (integration is! ProjectIntegrationConfig) {
                throw StateError(
                  'integrationRouteMap entries must be ProjectIntegrationConfig.',
                );
              }
              return integration;
            })
            .cast<ProjectIntegrationConfig>()
            .toList(growable: false),
      ),
    );
  }

  static Map<String, dynamic> encode(
    Map<EventType, List<ProjectIntegrationConfig>> mapping,
  ) {
    return mapping.map(
      (key, value) => MapEntry(
        EventTypeEncoder.encode(key),
        value
            .map((project) => IntegrationConfigEncoder.encode(project))
            .cast<Map<String, dynamic>>()
            .toList(growable: false),
      ),
    );
  }
}
