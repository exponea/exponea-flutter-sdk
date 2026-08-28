part of 'configuration_change.dart';

@immutable
final class IntegrationConfigurationChange extends ConfigurationChange {
  final IntegrationConfig? integrationConfig;
  final Map<EventType, List<ProjectIntegrationConfig>>? integrationRouteMap;

  const IntegrationConfigurationChange({
    this.integrationConfig,
    this.integrationRouteMap,
  });
}
