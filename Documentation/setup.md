---
title: Initial setup for Flutter SDK
slug: flutter-sdk-setup
category:
  uri: /branches/2/categories/guides/Developers
parent:
  uri: flutter-sdk
content:
  excerpt: Install and configure the Flutter SDK
---

## Install the SDK

The Exponea Flutter SDK can be installed or updated through a dependency in your app's [pubspec](https://docs.flutter.dev/tools/pubspec). [CocoaPods](https://cocoapods.org/) is required to set up the iOS app.

> 📘
>
> Refer to [Flutter SDK release notes](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-release-notes) for the latest Exponea Flutter SDK release.

> ❗️
>
> **SDK versions 3.0.0 and higher** require **Dart 3.0+** and **Flutter 3.10+** (sealed-class API for Stream/JWT integration types). Upgrade your toolchain before updating to a JWT/Stream release. For more information, see [Flutter SDK version update guide](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-version-update#update-to-version-300-or-higher).

### Add dependency

In your project's `pubspec.yaml` file, add a dependency to the Exponea Flutter SDK under `dependencies:`:

```yaml
dependencies:
  exponea: 1.6.0
```

Optionally, you can specify a minimum version (for example, `^1.6.0`) or a version range (for example, `>=1.6.0 < 2.0.0`) instead of a specific version. Refer to [Version constraints](https://cocoapods.org/) in the Dart dependencies documentation for details.

### iOS setup

To resolve the Exponea SDK dependencies for the iOS app, first `cd` into the `ios` directory in your project:

```shell
cd ios
```

Then run the following command:

```shell
pod install
```

The minimum supported iOS version for the SDK is 15.0. You may need to change the iOS version on the first line of your `ios/Podfile` to `platform :ios, '15.0'`, or higher.

> ❗️
>
> **Xcode 27 compatibility:** CocoaPods sets each pod target's deployment target from that pod's podspec, not from your app's `platform :ios` line alone. Flutter plugins and other transitive dependencies may still declare iOS 9.0–13.0. Add or merge the following `post_install` hook in your `ios/Podfile` (keep any existing `flutter_additional_ios_build_settings` call):
>
> ```ruby
> post_install do |installer|
>   installer.pods_project.targets.each do |target|
>     target.build_configurations.each do |config|
>       deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
>       if deployment_target.nil? || deployment_target.to_f < 15.0
>         config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
>       end
>     end
>     flutter_additional_ios_build_settings(target)
>   end
> end
> ```
>
> After changing the Podfile, run `pod install` again. Set **iOS Deployment Target** to 15.0 or higher for your app target and any notification extensions in Xcode.

### Android setup

The minimum supported Android API level for the SDK is 24. You may need to set or update `minSdkVersion` in `android/app/build.gradle` to `24` or higher:

```gradle
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 24
    }
```

#### Android Auto Backup and SDK SharedPreferences

The Flutter SDK relies on the [native Android SDK](https://documentation.bloomreach.com/engagement/docs/android-sdk) to persist data in dedicated SharedPreferences files, for example `EXPONEA_PREFERENCES.xml` and `EXPONEA_PUSH_TOKEN.xml`. The native SDK ships with default Android Auto Backup rules that exclude only the push token and short-lived authentication data from backup.

If your app doesn't define its own backup rules, the SDK defaults apply automatically. No additional action required.

If your app defines its own backup rules, or you want to exclude SDK SharedPreferences from Auto Backup, configure them in your Flutter project's Android host app:

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/xml/backup_rules.xml` (API 30 and below)
- `android/app/src/main/res/xml/data_extraction_rules.xml` (API 31 and above)

> 📘
>
> For XML examples and default backup behavior, follow the instructions in [Android Auto Backup and SDK SharedPreferences](https://documentation.bloomreach.com/engagement/docs/android-sdk-setup#android-auto-backup-and-sdk-sharedpreferences) in the native Android SDK documentation.
>
> If you get a build error such as `Manifest merger failed` for `fullBackupContent` or `dataExtractionRules`, see [Build error "Manifest merger failed"](https://documentation.bloomreach.com/engagement/docs/android-sdk-setup#build-error-manifest-merger-failed) in the native Android SDK documentation.

## Initialize the SDK

Now that you have installed the SDK in your project, you must import, configure, and initialize the SDK in your application code.

> ❗️ Protect the privacy of your customers
>
> Make sure you have obtained and stored tracking consent from your customer before initializing Exponea Flutter SDK.
>
> To ensure you're not tracking events without the customer's consent, you can use `ExponeaPlugin().clearLocalCustomerData(appGroup)` when a customer opts out from tracking (this applies to new users or returning customers who have previously opted out). This will bring the SDK to a state as if it was never initialized. This option also prevents reusing existing cookies for returning customers.
>
> Refer to [Clear local customer data](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking#clear-local-customer-data) for details.
>
> If the customer denies tracking consent after Exponea Flutter SDK is initialized, you can use `ExponeaPlugin().stopIntegration()` to stop SDK integration and remove all locally stored data.
>
> Refer to [Stop SDK integration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking#stop-sdk-integration) for details.

The required configuration parameter is `integrationConfig`. Choose one of two types depending on your integration:

- **`ProjectIntegrationConfig`** — for a standard {user.mkg} integration. Requires `projectToken`, `authorizationToken`, and `baseUrl`. Find your credentials in the {user.mkg} webapp under **Project settings** > **Access management** > **API**.
- **`StreamIntegrationConfig`** — for a {user.dh} [event stream](https://documentation.bloomreach.com/data-hub/docs/event-streams) integration. Requires `streamId` and an optional `baseUrl`. Find your stream ID in the {user.dh} app under **Event streams** > select your stream > **Access Security**.

> 📘
>
> Refer to [Mobile SDKs API access management](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management) for details.

Import the SDK:

```dart
import 'package:exponea/exponea.dart';
```

Initialize the SDK with a `ProjectIntegrationConfig`:

```dart
final _plugin = ExponeaPlugin();
final configuration = ExponeaConfiguration(
  integrationConfig: ProjectIntegrationConfig(
    projectToken: 'YOUR_PROJECT_TOKEN',
    authorizationToken: 'Token YOUR_API_KEY',
    // default baseUrl value is https://api.exponea.com
    baseUrl: 'YOUR_API_BASE_URL',
  ),
);
await _plugin.configure(configuration).catchError((error) {
  print('Error: $error');
  return false;
});
```

Or initialize with a `StreamIntegrationConfig`:

```dart
final _plugin = ExponeaPlugin();
final configuration = ExponeaConfiguration(
  integrationConfig: StreamIntegrationConfig(
    streamId: 'YOUR_STREAM_ID',
    // default baseUrl value is https://api.exponea.com
    baseUrl: 'YOUR_API_BASE_URL',
  ),
);
await _plugin.configure(configuration).catchError((error) {
  print('Error: $error');
  return false;
});
```

> 📘 Note
>
> - For detailed JWT setup, see [SDK auth token authorization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization#sdk-auth-token-authorization).
> - See the {user.dh} documentation to learn how to [configure Flutter SDK with JWT authentication](https://documentation.bloomreach.com/data-hub/docs/configure-flutter-sdk-with-jwt-authentication) for event streams.

### Initialize with customer identity

Optionally, provide a `CustomerIdentity` as the `customerIdentifier` argument to `configure()` to identify the customer immediately during initialization:

```dart
final _plugin = ExponeaPlugin();

final customerIdentity = CustomerIdentity(
  customerIds: {'registered': 'jane.doe@example.com'},
  sdkAuthToken: 'your-jwt-token',
);

await _plugin.configure(
  ExponeaConfiguration(
    integrationConfig: StreamIntegrationConfig(
      streamId: 'YOUR_STREAM_ID',
      baseUrl: 'YOUR_API_BASE_URL',
    ),
  ),
  customerIdentifier: customerIdentity,
);
```

For Stream integrations, subscribe to `sdkAuthErrorStream` before `configure()` so auth errors during initialization are handled immediately. For more information, see [sdkAuthErrorStream](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization#sdkautherrorstream).

Legacy initialization with flat project fields (deprecated) still works:

```dart
final configuration = ExponeaConfiguration(
  projectToken: 'YOUR_PROJECT_TOKEN',
  authorizationToken: 'YOUR_API_KEY',
  baseUrl: 'YOUR_API_BASE_URL',
);
await _plugin.configure(configuration);
```

#### Configure application ID

**Multiple mobile apps:** If your {user.mkg} project supports multiple mobile apps, specify the `applicationId` in your configuration. This helps distinguish between different apps in your project.


```dart
final configuration = ExponeaConfiguration(
    ...
    applicationId: '<Your application id>',
    ...
```

Make sure your `applicationId` value matches exactly Application ID configured in your {user.mkg} under **Project Settings > Campaigns > Channels > Push Notifications.**

**Single mobile app:** If your {user.mkg} project supports only one app, you can skip the `applicationId` configuration. The SDK will automatically use the default value "default-application".


### Configure the SDK on every Flutter engine attach

Flutter application code can reload without restarting the native application. In add-to-app integrations, Flutter engines can also be stopped and recreated while the underlying native SDK keeps running.

In both cases, the plugin loses its push notification and in-app message bindings and its configuration cache becomes stale. Call `configure(...)` on every Flutter engine attach to restore these bindings and refresh the cache.

`configure(...)` is idempotent: only the first call initializes the underlying native SDK. Subsequent calls leave the live native configuration untouched, rebind the plugin's event listeners, refresh the plugin's configuration cache, and return `false`.

```dart
Future<void> configureExponea(ExponeaConfiguration configuration) async {
  try {
    final initialized = await _plugin.configure(configuration);
    if (!initialized) {
      print('Exponea SDK already configured; plugin state refreshed.');
    }
  } catch (error) {
    print('Error: $error');
  }
}
```

You can still query `ExponeaPlugin().isConfigured()` to distinguish the first initialization from a subsequent reattach—for example, to skip one-off setup that doesn't need to repeat. The host app must re-register any per-engine subscriptions it set up explicitly on the new engine, such as `registerSegmentationDataStream` callbacks.

### Done!

The SDK is now active and should be tracking sessions in your app.

## Other SDK configuration

### Advanced configuration

The SDK can be further configured by setting additional properties of the `ExponeaConfiguration` object. For a complete list of available configuration parameters, refer to the [Configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration) documentation.

### Log level

The SDK supports the following log levels defined in `LogLevel`:

| Log level | Description |
| ----------| ----------- |
| `off`     | Disables all logging |
| `error`   | Serious errors or breaking issues |
| `warning` | Warnings and recommendations + `error` |
| `info`    | Informative messages + `warning` + `error` |
| `debug`   | Debugging information + `info` + `warning` + `error`  |
| `verbose` | Information about all SDK actions + `debug` + `info` + `warning` + `error`. |

The default log level is `info`. While developing or debugging, setting the log level to `debug` or `verbose` can be helpful.

You can set the log level at runtime as follows:

```dart
_plugin.setLogLevel(LogLevel.verbose);
```

### Data flushing

Read [Data flushing](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-data-flushing) to learn more about how the SDK uploads data to the {user.mkg} API and how to customize this behavior.
