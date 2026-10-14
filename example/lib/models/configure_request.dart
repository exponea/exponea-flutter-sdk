import 'package:exponea_example/models/integration_mode.dart';

class ConfigureRequest {
  const ConfigureRequest({
    required this.mode,
    required this.baseUrl,
    this.projectToken = '',
    this.authorizationToken = '',
    this.advancedAuthToken = '',
    this.streamId = '',
    this.jwtKeyId = '',
    this.jwtSecret = '',
    this.customerId = '',
    this.applicationId = '',
  });

  final IntegrationMode mode;
  final String baseUrl;
  final String projectToken;
  final String authorizationToken;
  final String advancedAuthToken;
  final String streamId;
  final String jwtKeyId;
  final String jwtSecret;
  final String customerId;
  final String applicationId;

  bool get isBaseUrlValid {
    if (baseUrl.isEmpty) return false;
    final uri = Uri.tryParse(baseUrl);
    return uri != null &&
        uri.isAbsolute &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  bool get isProjectValid =>
      isBaseUrlValid &&
      projectToken.isNotEmpty &&
      authorizationToken.isNotEmpty;

  bool get isStreamValid => isBaseUrlValid && streamId.isNotEmpty;

  bool get isJwtPairValid =>
      jwtKeyId.isEmpty == jwtSecret.isEmpty;

  bool get isValid {
    if (!isJwtPairValid) {
      return false;
    }
    return mode == IntegrationMode.project ? isProjectValid : isStreamValid;
  }
}
