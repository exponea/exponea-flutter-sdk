import 'package:exponea_example/features/authentication/auth_preferences.dart';
import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AuthPreferences load returns empty form on first run', () async {
    SharedPreferences.setMockInitialValues({});

    final data = await AuthPreferences.load();

    expect(data.mode, IntegrationMode.project);
    expect(data.projectToken, isEmpty);
    expect(data.baseUrl, isEmpty);
  });

  test('AuthPreferences save and load round-trip', () async {
    SharedPreferences.setMockInitialValues({});

    const request = ConfigureRequest(
      mode: IntegrationMode.project,
      baseUrl: 'https://api.example.com',
      projectToken: 'proj',
      authorizationToken: 'auth',
      customerId: 'cust-1',
    );
    await AuthPreferences.save(request);

    final loaded = await AuthPreferences.load();

    expect(loaded.mode, IntegrationMode.project);
    expect(loaded.baseUrl, 'https://api.example.com');
    expect(loaded.projectToken, 'proj');
    expect(loaded.authorizationToken, 'auth');
    expect(loaded.customerId, 'cust-1');
  });
}
