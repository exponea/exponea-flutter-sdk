# Basic concepts
Exponea SDK is written as a wrapper around native SDKs using [platform channels](https://flutter.dev/docs/development/platform-integration/platform-channels#architecture). Messages and responses are passed asynchronously, to ensure the user interface remains responsive. The result is that our interface is also asynchronous, there are no properties that you can access synchronously.

## Futures
Functions of the SDK return futures that can reject in case of data format error, native SDK not being configured or error inside native SDK itself. You should always handle the errors.

### Examples
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

## Hot reload
Flutter applications code can be reloaded without restarting the native application itself, which speeds up the development process, but it also means that native code usually continues to run as if nothing happens. You should only configure the SDK once, when developing with hot reload enabled, you should check `ExponeaPlugin().isConfigured()` before configuring Exponea SDK.

### Example
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
As with everything that's supposed to work automatically, the biggest problem is, what to do when it doesn't.
These are frequent compilation issues, faced when integrating SDK, and the most likely solutions.

### Missing Swift standard libraries (iOS specific)
If your log contains warnings like

``` 
ld: warning: Could not find or use auto-linked library 'swiftFoundation'
ld: warning: Could not find or use auto-linked library 'swiftCompatibility51'
ld: warning: Could not find or use auto-linked library 'swiftMetal'
ld: warning: Could not find or use auto-linked library 'swiftDarwin'
ld: warning: Could not find or use auto-linked library 'swiftCloudKit'
ld: warning: Could not find or use auto-linked library 'swiftUIKit'
```

it means that Swift standard libraries are missing and that's why the Exponea SDK's Swift files produce various errors.
Solution here is to add an empty Swift file into **\<project root dir\>/ios**, e.g. File.swift with empty content:

`import Foundation`

This needs to be done in Xcode (File -> New -> File -> Swift File). 
When Xcode asks you if you want to create bridging headers, it's not necessary to do so, but we recommend it,
since missing bridging header can lead to compilation errors when using Xcode 12.5 (e.g. [in this github issue](https://github.com/exponea/exponea-react-native-sdk/issues/19) )

After cleaning the project, a build should succeed.

[Check similar issue on github](https://github.com/exponea/exponea-react-native-sdk/issues/12)

###  Not specified SWIFT_VERSION (iOS specific)
If SWIFT_VERSION is not set, there may be some Swift compilation errors in the Exponea iOS SDK in the Swift files.
For example:

`Cannot convert value of type 'T??' to specified type 'NSDictionary?'`

The SWIFT_VERSION can be either added via **Podfile**

`ENV['SWIFT_VERSION'] = '5'`

or it can be set in **User Defined section** in Xcode.

`SWIFT_VERSION = 5`

[Check similar issue on github](https://github.com/exponea/exponea-react-native-sdk/issues/12)
