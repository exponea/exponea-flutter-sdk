import 'package:meta/meta.dart';

sealed class IntegrationConfig {
  const IntegrationConfig();
}

@immutable
final class ProjectIntegrationConfig extends IntegrationConfig {
  final String projectToken;
  final String authorizationToken;
  final String? baseUrl;

  const ProjectIntegrationConfig({
    required this.projectToken,
    required this.authorizationToken,
    this.baseUrl,
  });
}

@immutable
final class StreamIntegrationConfig extends IntegrationConfig {
  final String streamId;
  final String? baseUrl;

  const StreamIntegrationConfig({
    required this.streamId,
    this.baseUrl,
  });
}
