# Exponea Flutter SDK example app

Example app for the Exponea Flutter SDK. Each SDK feature has its own screen, and every interactive element carries a stable automation identifier, so the app works both as a reference implementation and as a target for UI automation.

## Toolchain

Developed with **Flutter 3.44.1** / **Dart 3.12.1** (latest stable at scaffold time).

`pubspec.yaml` constraints (plugin-published support range):

- Dart: `>=3.0.0 <4.0.0`
- Flutter: `>=3.10.0`

## Run

```bash
cd example
flutter pub get
# Android needs a flavor: gms (Firebase) or hms (Huawei). iOS has no flavors.
flutter run --flavor gms \
  --dart-define=EXPONEA_PROJECT_TOKEN=... \
  --dart-define=EXPONEA_AUTHORIZATION_TOKEN=... \
  --dart-define=EXPONEA_BASE_URL=... \
  --dart-define=EXPONEA_CUSTOMER_ID=... \
  --dart-define=EXPONEA_STREAM_ID=...
```

Local credentials files (gitignored secrets) — copy from the templates:

```bash
cp android/credentials.example.json android/credentials.json
cp ios/credentials.example.json ios/credentials.json
# then fill in STREAM_ID / JWT / customer id
```

- `android/credentials.json` / `ios/credentials.json` (gitignored)
- `android/credentials.example.json` / `ios/credentials.example.json` (committed templates)

```bash
# Prefill auth form only (manual Start) — set EXPONEA_AUTO_CONFIGURE=false
flutter run -d emulator-5554 --flavor gms --dart-define-from-file=android/credentials.json
flutter run -d "iPhone 17" --dart-define-from-file=ios/credentials.json

# Appium / CI auto-login — omit EXPONEA_AUTO_CONFIGURE or set it to true
```

Keys: `EXPONEA_PROJECT_TOKEN`, `EXPONEA_AUTHORIZATION_TOKEN`, `EXPONEA_BASE_URL`, `EXPONEA_CUSTOMER_ID`, `EXPONEA_STREAM_ID`, `EXPONEA_JWT_KEY_ID`, `EXPONEA_JWT_SECRET`, `EXPONEA_INTEGRATION_MODE`, `EXPONEA_AUTO_CONFIGURE`.

### Android flavors and signing

- `gms` uses Firebase Cloud Messaging (`android/app/google-services.json`).
- `hms` uses Huawei Push Kit (`android/app/agconnect-services.json`) and needs a device with HMS Core.
- Debug and release builds are signed with the shared demo key `android/app/Exponea.jks`. If a build signed with another key is installed, uninstall it once before installing a new build.

### iOS rich push

The `ExampleNotificationService` and `ExampleNotificationContent` extensions (App Group `group.com.exponea.sdk.example`) handle images, action buttons and delivery tracking. Rich push needs a physical device.

## Test

```bash
cd example && flutter test
```

Automation identifiers (`Semantics(identifier: ...)`) are listed in `test/contract/automation_contract.yaml`, and `test/contract/contract_test.dart` checks them.

### Plugin native unit tests

The example app also hosts the plugin's native unit tests. They read fixtures from the repository `test/values/`.

```bash
# Android (Kotlin)
cd example/android && ./gradlew :app:testGmsDebugUnitTest
# iOS (Quick/Nimble), after flutter pub get and pod install
cd example/ios && xcodebuild test -workspace Runner.xcworkspace -scheme Runner \
  -only-testing:RunnerTests -destination 'platform=iOS Simulator,name=iPhone 17'
```
