import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/util/authorization_token.dart';

class EnvConfig {
  const EnvConfig({
    required this.projectToken,
    required this.authorizationToken,
    required this.baseUrl,
    required this.customerId,
    required this.streamId,
    required this.jwtKeyId,
    required this.jwtSecret,
    required this.integrationMode,
    this.autoConfigure = '',
  });

  final String projectToken;
  final String authorizationToken;
  final String baseUrl;
  final String customerId;
  final String streamId;
  final String jwtKeyId;
  final String jwtSecret;
  final String integrationMode;

  /// When `"false"`, skip auto-configure and only prefill the auth form.
  /// Empty / `"true"` keeps Automation Contract auto-configure behaviour.
  final String autoConfigure;

  static EnvConfig fromEnvironment() {
    return EnvConfig(
      projectToken: const String.fromEnvironment('EXPONEA_PROJECT_TOKEN'),
      authorizationToken:
          const String.fromEnvironment('EXPONEA_AUTHORIZATION_TOKEN'),
      baseUrl: const String.fromEnvironment('EXPONEA_BASE_URL'),
      customerId: const String.fromEnvironment('EXPONEA_CUSTOMER_ID'),
      streamId: const String.fromEnvironment('EXPONEA_STREAM_ID'),
      jwtKeyId: const String.fromEnvironment('EXPONEA_JWT_KEY_ID'),
      jwtSecret: const String.fromEnvironment('EXPONEA_JWT_SECRET'),
      integrationMode:
          const String.fromEnvironment('EXPONEA_INTEGRATION_MODE'),
      autoConfigure: const String.fromEnvironment('EXPONEA_AUTO_CONFIGURE'),
    );
  }

  IntegrationMode get resolvedMode {
    if (integrationMode.toLowerCase() == 'stream') {
      return IntegrationMode.stream;
    }
    if (integrationMode.isEmpty &&
        streamId.isNotEmpty &&
        projectToken.isEmpty) {
      return IntegrationMode.stream;
    }
    return IntegrationMode.project;
  }

  bool get hasProjectCredentials =>
      projectToken.isNotEmpty &&
      authorizationToken.isNotEmpty &&
      baseUrl.isNotEmpty;

  bool get hasStreamCredentials => streamId.isNotEmpty && baseUrl.isNotEmpty;

  bool get canAutoConfigure {
    return resolvedMode == IntegrationMode.stream
        ? hasStreamCredentials
        : hasProjectCredentials;
  }

  /// Auto-configure unless explicitly disabled via `EXPONEA_AUTO_CONFIGURE=false`.
  bool get shouldAutoConfigure {
    if (autoConfigure.toLowerCase() == 'false') {
      return false;
    }
    return canAutoConfigure;
  }

  ConfigureRequest toConfigureRequest() {
    return ConfigureRequest(
      mode: resolvedMode,
      baseUrl: baseUrl,
      projectToken: projectToken,
      authorizationToken: normalizeAuthorizationToken(authorizationToken),
      streamId: streamId,
      jwtKeyId: jwtKeyId,
      jwtSecret: jwtSecret,
      customerId: customerId,
    );
  }
}
