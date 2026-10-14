import 'package:exponea_example/app/env_config.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EnvConfig.fromEnvironment reads dart-define keys', () {
    const config = EnvConfig(
      projectToken: 'proj',
      authorizationToken: 'auth',
      baseUrl: 'https://api.example.com',
      customerId: 'cust',
      streamId: 'stream',
      jwtKeyId: '',
      jwtSecret: '',
      integrationMode: '',
    );

    expect(config.hasProjectCredentials, isTrue);
    expect(config.projectToken, 'proj');
    expect(config.resolvedMode, IntegrationMode.project);
    expect(config.canAutoConfigure, isTrue);
  });

  test('EnvConfig stream mode resolves from integration mode env', () {
    const config = EnvConfig(
      projectToken: '',
      authorizationToken: '',
      baseUrl: 'https://api.example.com',
      customerId: '',
      streamId: 'stream-1',
      jwtKeyId: '',
      jwtSecret: '',
      integrationMode: 'stream',
    );

    expect(config.resolvedMode, IntegrationMode.stream);
    expect(config.hasStreamCredentials, isTrue);
    expect(config.canAutoConfigure, isTrue);
    expect(config.shouldAutoConfigure, isTrue);
    expect(config.toConfigureRequest().mode, IntegrationMode.stream);
  });

  test('EXPONEA_AUTO_CONFIGURE=false disables auto-configure', () {
    const config = EnvConfig(
      projectToken: '',
      authorizationToken: '',
      baseUrl: 'https://api.example.com',
      customerId: '',
      streamId: 'stream-1',
      jwtKeyId: '',
      jwtSecret: '',
      integrationMode: 'stream',
      autoConfigure: 'false',
    );

    expect(config.canAutoConfigure, isTrue);
    expect(config.shouldAutoConfigure, isFalse);
  });

  test('toConfigureRequest strips Token prefix from authorization', () {
    const config = EnvConfig(
      projectToken: 'proj',
      authorizationToken: 'Token secret-auth',
      baseUrl: 'https://api.example.com',
      customerId: '',
      streamId: '',
      jwtKeyId: '',
      jwtSecret: '',
      integrationMode: '',
    );

    expect(config.toConfigureRequest().authorizationToken, 'secret-auth');
  });
}
