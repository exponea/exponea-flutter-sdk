import 'package:exponea_example/main.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/logging/sdk_log_store.dart';
import 'package:exponea_example/services/exponea_service.dart';
import 'package:exponea_example/services/fake_exponea_service.dart';
import 'package:exponea_example/services/sdk_status_store.dart';
import 'package:exponea_example/util/sdk_setup_state.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpExampleApp(
  WidgetTester tester, {
  ExponeaService? service,
  SdkLogStore? sdkLogStore,
  bool skipLoading = true,
  bool startOnShell = false,
  bool streamMode = false,
}) async {
  SdkSetupState.reset();
  if (streamMode) {
    SdkSetupState.setStreamConfig(IntegrationMode.stream);
  }
  final resolved = service ?? FakeExponeaService();
  // Shell tests historically start without a full configure() (cookie / config
  // sheet still show empty state). Mark lifecycle anonymous so Fetching shows
  // App Inbox controls (hidden only when notInitialized after stop).
  if (startOnShell && !resolved.isConfigured) {
    resolved.statusStore.set(SdkLifecycleState.anonymous);
  }
  await tester.pumpWidget(
    buildExampleApp(
      service: resolved,
      sdkLogStore: sdkLogStore,
      skipLoading: skipLoading,
      startOnShell: startOnShell,
    ),
  );
  await tester.pumpAndSettle();
}
