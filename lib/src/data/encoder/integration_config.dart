import '../model/integration_config.dart';
import '../util/object.dart';

abstract class IntegrationConfigEncoder {
  static IntegrationConfig decode(Map<String, dynamic> data) {
    final streamId = data.getOptional<String>('streamId');
    final projectToken = data.getOptional<String>('projectToken');

    if (streamId != null) {
      if (projectToken != null) {
        throw StateError(
          'integrationConfig cannot contain both streamId and projectToken',
        );
      }
      return StreamIntegrationConfig(
        streamId: streamId,
        baseUrl: data.getOptional('baseUrl'),
      );
    }

    return ProjectIntegrationConfig(
      projectToken: data.getRequired('projectToken'),
      authorizationToken: data.getRequired('authorizationToken'),
      baseUrl: data.getOptional('baseUrl'),
    );
  }

  static Map<String, dynamic> encode(IntegrationConfig config) {
    return switch (config) {
      ProjectIntegrationConfig(
        :final projectToken,
        :final authorizationToken,
        :final baseUrl,
      ) =>
        {
          'projectToken': projectToken,
          'authorizationToken': authorizationToken,
          'baseUrl': baseUrl,
        }..removeWhere((key, value) => value == null),
      StreamIntegrationConfig(:final streamId, :final baseUrl) => {
          'streamId': streamId,
          'baseUrl': baseUrl,
        }..removeWhere((key, value) => value == null),
    };
  }
}
