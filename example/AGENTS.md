# Example app

Apply the root guide as well. Commands below run from `example/` unless noted. `example/README.md` is the authoritative run guide; keep it and `Documentation/example-app.md` in sync with any screen or flow change.

- The example depends on the plugin by path (`exponea: path: ../`). Do not switch it to a pub.dev version to hide a local build failure.
- Android requires a flavor: `flutter run --flavor gms` (Firebase) or `flutter run --flavor hms` (Huawei). A bare `flutter run` fails on Android. iOS has no flavors.
- iOS: `flutter pub get`, then `cd ios && pod install`, then `flutter run`. The Podfile forces `IPHONEOS_DEPLOYMENT_TARGET` to the SDK minimum in `post_install`; keep that hook when editing the Podfile.
- Credentials come from `--dart-define` keys (`EXPONEA_PROJECT_TOKEN`, `EXPONEA_STREAM_ID`, `EXPONEA_AUTO_CONFIGURE`, ...) read by `lib/app/env_config.dart`. Local values go in `android/credentials.json` or `ios/credentials.json` via `--dart-define-from-file`; both are gitignored. Only the `credentials.example.json` templates are committed, and they stay empty.
- The example is also the host for the native plugin tests. See [android/AGENTS.md](../android/AGENTS.md) and [ios/AGENTS.md](../ios/AGENTS.md) for the Gradle and `xcodebuild` commands.
- The example version in `pubspec.yaml` (`X.Y.Z+N`) must equal the plugin version; both platforms read it from there (`flutter.versionName` on Android, `$(FLUTTER_BUILD_NAME)` in `ios/Runner/Info.plist`). Only the release script bumps `X.Y.Z` there; the `+N` build number stays `1` (the script's `flutter.versionCode` increment goes to the gitignored `android/local.properties`, which Flutter rewrites from `pubspec.yaml` on every build). The example has a looser SDK constraint and a newer `flutter_lints` than the plugin; do not align those with the plugin in a feature PR.

## Structure

- `lib/main.dart` wires `buildExampleApp(...)`; `lib/app/` holds the shell, theme and `EnvConfig`; `lib/features/<feature>/` holds one screen per SDK area (authentication, tracking, flushing, fetching, anonymize, content_blocks, app_inbox).
- `lib/services/exponea_service.dart` is the abstraction every screen talks to. `plugin_exponea_service.dart` calls the real `ExponeaPlugin`; `fake_exponea_service.dart` backs widget tests. Add a new SDK call to the interface, both implementations and the fake's log output.
- `lib/logging/` is the in-app log store fed by Dart and by native `SdkLogBridge` (Kotlin and Swift) through an event channel. `lib/navigation/` resolves deep links delivered by `ExampleDeeplinkHostPlugin` (iOS) and `MainActivity` (Android).
- Every interactive widget carries `Semantics(identifier: ...)`. Identifiers are declared in `test/contract/automation_contract.yaml` and verified by `test/contract/contract_test.dart`; UI automation depends on them, so add a contract entry for every new control and never rename an existing one silently.
- `lib/util/local_jwt_generator.dart` is demo-only HMAC signing for stream integration. Never recommend it for production and never move it into the plugin.
- `android/app/src/{gms,hms}/` hold the flavor-specific messaging services; `android/app/src/main/` holds `ExampleApplication`, `MainActivity` (`singleTask`, verified app links on `mobile-sdk-example-apps.web.app`) and `ExampleAuthProvider` registered via manifest meta-data `ExponeaAuthProvider`.
- `ios/Runner/AppDelegate.swift` extends `ExponeaFlutterAppDelegate`, adopts `FlutterImplicitEngineDelegate` and hosts the scene delegate, deep-link plugin and log bridge; it is the reference integrators copy. `ios/ExampleNotificationService` and `ios/ExampleNotificationContent` are the rich-push extensions sharing App Group `group.com.exponea.sdk.example`.

## Tests and verification

- `flutter test` runs unit, widget and contract tests with `FakeExponeaService`; `test/helpers/pump_app.dart` is the entry point for widget tests. `lib/util/test_environment.dart` detects the widget-test binding so platform views are skipped there.
- `flutter analyze` from the repo root already covers `example/` and exits 1 on pre-existing infos; do not add new issues. Pre-existing infos in tests are baseline.
- `android/app/google-services.json` is checked in and listed under `false_secrets` in the root `pubspec.yaml`; `android/app/Exponea.jks` with its password in `android/app/build.gradle.kts` is a shared demo signing key, whitelisted in `android/.gitignore`. Do not reuse either elsewhere and do not add real project tokens anywhere in the tree.
- Running the app contacts whatever backend the credentials point to. Automated checks never require a live project.
- Push, universal links, platform views and lifecycle (hot restart, background, UIScene) need a device or simulator. Record which scenarios you verified and which you could not; a successful build does not prove push delivery.
