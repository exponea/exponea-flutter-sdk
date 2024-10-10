---
title: Basic concepts
excerpt: Basic concepts of the Flutter SDK and some troubleshooting tips.
slug: flutter-sdk-basic-concepts
categorySlug: integrations
parentDocSlug: flutter-sdk
---

## Basic concepts

The Exponea Flutter SDK is written as a wrapper around our native [Android](https://documentation.bloomreach.com/engagement/docs/android-sdk) and [iOS](https://documentation.bloomreach.com/engagement/docs/ios-sdk) SDKs using [platform channels](https://flutter.dev/docs/development/platform-integration/platform-channels#architecture). Messages and responses are passed asynchronously to ensure the user interface remains responsive. As a result, our interface is also asynchronous; there are no properties you can access synchronously.

The Flutter SDK exposes most Engagement functionality in a platform-agnostic way. However, some features require integrating directly with the underlying native Android and iOS SDKs and writing custom platform-specific code. Therefore, besides Flutter experience, some knowledge of Kotlin (Android) and Swift (iOS) is required.

The documentation indicates whenever platform-specific code is required, provides examples, and links to the relevant documentation of the native Android and iOS SDKs for more details.

### Futures

Functions of the SDK return futures that can reject in case of a data format error, the native SDK not being configured, or an error inside the native SDK itself. You should always handle the errors.

#### Examples

```dart
import 'package:exponea/exponea.dart';

final _plugin = ExponeaPlugin();

void cookieLogger() {
  _plugin.getCustomerCookie()
    .then((cookie) => print(cookie))
    .catchError((error) => print('Error: $error'));
}
```
or
```dart
Future<void> cookieLogger() async {
  try {
    final cookie = await _plugin.getCustomerCookie();
    print(cookie);
  } catch (error) {
    print('Error: $error');
  }
}
```

### Hot reload

Flutter applications code can be reloaded without restarting the native application itself. This speeds up the development process, but it also means that native code usually continues to run as if nothing happened. You should only configure the SDK once. When developing with hot reload enabled, you should check `ExponeaPlugin().isConfigured()` before configuring the SDK.

#### Example

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

## Troubleshooting

Below are some common compilation issues encountered while integrating the SDK, and their most likely solutions.

### Missing Swift standard libraries (iOS-specific)

If your log contains warnings like the following:

``` 
ld: warning: Could not find or use auto-linked library 'swiftFoundation'
ld: warning: Could not find or use auto-linked library 'swiftCompatibility51'
ld: warning: Could not find or use auto-linked library 'swiftMetal'
ld: warning: Could not find or use auto-linked library 'swiftDarwin'
ld: warning: Could not find or use auto-linked library 'swiftCloudKit'
ld: warning: Could not find or use auto-linked library 'swiftUIKit'
```

It means that Swift standard libraries are missing, causing the SDK's Swift files to produce various errors.

The solution is to add a Swift file into **\<project root dir\>/ios**, for example. `File.swift`, with the following content:

```swift
import Foundation
```

You must do this in Xcode (`File` -> `New` -> `File` -> `Swift File`).

When Xcode asks you if you want to create bridging headers, we recommend you do so, since a missing bridging header can lead to compilation errors when using Xcode 12.5 (for example, [in this GitHub issue](https://github.com/exponea/exponea-react-native-sdk/issues/19)).

After cleaning the project, a build should succeed.

> 📘
>
> [Check similar issue on GitHub](https://github.com/exponea/exponea-react-native-sdk/issues/12)

### SWIFT_VERSION not specified (iOS-specific)

If `SWIFT_VERSION` is not set, there may be some Swift compilation errors in the Exponea iOS SDK in the Swift files.

For example:

`Cannot convert value of type 'T??' to specified type 'NSDictionary?'`

The SWIFT_VERSION can be specified either in the `Podfile`:

`ENV['SWIFT_VERSION'] = '5'`

Or it can be specified in the **User Defined section** in Xcode.

`SWIFT_VERSION = 5`

> 📘
>
> [Check similar issue on GitHub](https://github.com/exponea/exponea-react-native-sdk/issues/12)

### Events not tracked in app during first session

If your app is not tracking events during the first session but starts to track events on the next launch, you may not initialize the SDK properly.

- **SDK initialization sequence:** 
  Ensure that the `ExponeaPlugin`'s `configure()` method is called at an appropriate point in your app's initialization sequence. It should ideally be called early in the app's lifecycle, possibly in the `main()` function before `runApp()`. Ensure it's not being delayed or called conditionally in a way that might cause it to be skipped.
- **Dependency Initialization**:
  Check for any missing dependencies or prerequisites that the Exponea SDK relies on for initialization. Properly initialize these dependencies before calling the `ExponeaPlugin`'s `configure()` method.
- **Error Logging:**
  Implement error logging and handling in your app to capture any potential errors or exceptions that might occur during the initialization of the Exponea SDK. This can help you pinpoint the root cause of the issue.
- **SDK Version:**
  Check the version of your current SDK and ensure it is up to date.
