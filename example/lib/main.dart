import 'package:exponea_example/app/example_app.dart';
import 'package:exponea_example/logging/sdk_log_bridge.dart';
import 'package:exponea_example/logging/sdk_log_store.dart';
import 'package:exponea_example/logging/sdk_log_store_scope.dart';
import 'package:exponea_example/services/exponea_service.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/services/plugin_exponea_service.dart';
import 'package:exponea_example/services/sdk_status_scope.dart';
import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';

final SdkLogStore _sdkLogStore = SdkLogStore();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = PluginExponeaService();
  SdkLogBridge.connect(_sdkLogStore);
  service.setLogLevel(LogLevel.verbose);
  runApp(
    SdkLogStoreScope(
      store: _sdkLogStore,
      child: ExponeaServiceScope(
        service: service,
        child: SdkStatusScope(
          store: service.statusStore,
          child: const ExampleApp(),
        ),
      ),
    ),
  );
}

/// Test entry point with injectable service.
Widget buildExampleApp({
  required ExponeaService service,
  SdkLogStore? sdkLogStore,
  bool skipLoading = true,
  bool startOnShell = false,
}) {
  return SdkLogStoreScope(
    store: sdkLogStore ?? SdkLogStore(),
    child: ExponeaServiceScope(
      service: service,
      child: SdkStatusScope(
        store: service.statusStore,
        child: ExampleApp(
          skipLoading: skipLoading,
          startOnShell: startOnShell,
        ),
      ),
    ),
  );
}
