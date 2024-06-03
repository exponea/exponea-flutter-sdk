---
title: Initial SDK Setup
excerpt: Install and configure the Flutter SDK
slug: flutter-sdk-setup
categorySlug: integrations
parentDocSlug: flutter-sdk
---

## Install the SDK

The Exponea Flutter SDK can be installed or updated through a dependency in your app's [pubspec](https://docs.flutter.dev/tools/pubspec). [CocoaPods](https://cocoapods.org/) is required to set up the iOS app.

> 📘
>
> Refer to https://github.com/exponea/exponea-flutter-sdk/releases for the latest Exponea Android SDK release.

### Add Dependency

In your project's `pubspec.yaml` file, add a dependency to the Exponea Flutter SDK under `dependencies:`:

```yaml
dependencies:
  exponea: 1.6.0
```

Optionally, you can specify a minimum version (for example, `^1.6.0`) or a version range (for example, `>=1.6.0 < 2.0.0`) instead of a specific version. Refer to [Version constraints](https://cocoapods.org/) in the Dart dependencies documentation for details.

### iOS Setup

To resolve the Exponea SDK dependencies for the iOS app, first `cd` into the `ios` directory in your project:

```shell
cd ios
```

Then run the following command:

```shell
pod install
```

The minimum supported iOS version for the SDK is 11.0. You may need to change the iOS version on the first line of your `ios/Podfile` to `platform :ios, '11.0'`, or higher.

### Android Setup

The minimum supported Android API level for the SDK is 21. You may need to set or update `minSdkVersion` in `android/app/build.gradle` to `21` or higher:

```gradle
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 21
    }
```

## Initialize the SDK

Now that you have installed the SDK in your project, you must import, configure, and initialize the SDK in your application code.

The required configuration parameters are `projectToken`, `authorizationToken`, and `baseURL`. You can find these in the Bloomreach Engagement webapp under `Project settings` > `Access management` > `API`.

> 📘
>
> Refer to [Mobile SDKs API Access Management](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management) for details.

Import the SDK:

```dart
import 'package:exponea/exponea.dart';
```

Initialize the SDK:

```dart
final _plugin = ExponeaPlugin();
final configuration = ExponeaConfiguration(
  projectToken: 'YOUR_PROJECT_TOKEN',
  authorizationToken: 'YOUR_API_KEY',
  // default baseUrl value is https://api.exponea.com
  baseUrl: 'YOUR_API_BASE_URL', 
);
_plugin.configure(configuration).catchError((error) {
  print('Error: $error');
  return false;
});
```

### Configure the SDK Only Once

Flutter application code can be reloaded without restarting the native application itself. This speeds up the development process, but it also means that native code usually continues to run as if nothing happened. You should configure the SDK only once. When developing with hot reload enabled, you should check `ExponeaPlugin().isConfigured()` before configuring the SDK.

```dart
Future<void> configureExponea(ExponeaConfiguration configuration) {
  try {
    if (!await _plugin.isConfigured()) {
      _plugin.configure(configuration);
    } else {
      print("Exponea SDK already configured.");
    }
  } catch (error) {
    print('Error: $error');
  }
}
```

### Done!

At this point, the SDK is active and should now be tracking sessions in your app.

## Other SDK Configuration

### Advanced Configuration

The SDK can be further configured by setting additional properties of the `ExponeaConfiguration` object. For a complete list of available configuration parameters, refer to the [Configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration) documentation.

### Log Level

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

### Data Flushing

Read [Data Flushing](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-data-flushing) to learn more about how the SDK uploads data to the Engagement API and how to customize this behavior.
