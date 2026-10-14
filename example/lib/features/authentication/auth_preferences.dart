import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted auth form state (parity with legacy `example/lib/page/config.dart`).
class AuthFormData {
  const AuthFormData({
    required this.mode,
    this.projectToken = '',
    this.authorizationToken = '',
    this.advancedAuthToken = '',
    this.streamId = '',
    this.jwtKeyId = '',
    this.jwtSecret = '',
    this.customerId = '',
    this.baseUrl = '',
    this.applicationId = '',
  });

  final IntegrationMode mode;
  final String projectToken;
  final String authorizationToken;
  final String advancedAuthToken;
  final String streamId;
  final String jwtKeyId;
  final String jwtSecret;
  final String customerId;
  final String baseUrl;
  final String applicationId;
}

abstract final class AuthPreferences {
  static const _keyMode = 'integration_mode';
  static const _keyProject = 'project_token';
  static const _keyAuth = 'auth_token';
  static const _keyAdvancedAuth = 'advanced_auth_token';
  static const _keyStreamId = 'stream_id';
  static const _keyJwtKeyId = 'jwt_key_id';
  static const _keyJwtSecret = 'jwt_secret';
  static const _keyRegisteredId = 'registered_id';
  static const _keyBaseUrl = 'base_url';
  static const _keyApplicationId = 'application_id';

  static Future<AuthFormData> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AuthFormData(
      mode: preferences.getString(_keyMode) == 'stream'
          ? IntegrationMode.stream
          : IntegrationMode.project,
      projectToken: preferences.getString(_keyProject) ?? '',
      authorizationToken: preferences.getString(_keyAuth) ?? '',
      advancedAuthToken: preferences.getString(_keyAdvancedAuth) ?? '',
      streamId: preferences.getString(_keyStreamId) ?? '',
      jwtKeyId: preferences.getString(_keyJwtKeyId) ?? '',
      jwtSecret: preferences.getString(_keyJwtSecret) ?? '',
      customerId: preferences.getString(_keyRegisteredId) ?? '',
      baseUrl: preferences.getString(_keyBaseUrl) ?? '',
      applicationId: preferences.getString(_keyApplicationId) ?? '',
    );
  }

  static Future<void> save(ConfigureRequest request) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_keyMode, request.mode.envValue);
    await preferences.setString(_keyProject, request.projectToken);
    await preferences.setString(_keyAuth, request.authorizationToken);
    await preferences.setString(_keyAdvancedAuth, request.advancedAuthToken);
    await preferences.setString(_keyStreamId, request.streamId);
    await preferences.setString(_keyJwtKeyId, request.jwtKeyId);
    await preferences.setString(_keyJwtSecret, request.jwtSecret);
    await preferences.setString(_keyRegisteredId, request.customerId);
    await preferences.setString(_keyBaseUrl, request.baseUrl);
    await preferences.setString(_keyApplicationId, request.applicationId);
  }
}
