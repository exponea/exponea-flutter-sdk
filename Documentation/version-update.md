---
title: Flutter SDK version update guide
slug: flutter-sdk-version-update
category:
  uri: /branches/2/categories/guides/Developers
parent:
  uri: flutter-sdk-release-notes
content:
  excerpt: Update Exponea Flutter SDK in your app to a new version
---

This guide will help you upgrade your Exponea SDK to the new version.

## Update to version 3.0.0 or higher

Version 3.0.0 adds **Stream (Data hub) integration** and **JWT authentication** for the Tracking API Security feature, and adopts the UIScene lifecycle. Apple introduced a UIScene adoption warning in iOS 26 and will enforce it as a hard requirement in iOS 27.

### 1. Dart and Flutter version requirements

* **Flutter:** 3.38.0 or higher (`flutter upgrade`)
* **Dart:** 3.10.0 or higher (`sdk: '>=3.10.0 <4.0.0'`)

Apps on an older Flutter/Dart toolchain must upgrade before updating the SDK. Refer to the [Flutter upgrade guide](https://docs.flutter.dev/release/upgrade) and [Dart 3 migration guide](https://dart.dev/resources/dart-3-migration) if needed.

### 2. UIScene lifecycle adoption

Follow Flutter's [UISceneDelegate adoption guide](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate) to update your iOS app:

- Extend `ExponeaFlutterAppDelegate` — push notification delegate setup is automatic unless you override `application(_:didFinishLaunchingWithOptions:)`. If you override it, call `configurePushNotificationDelegate()` at the start of your override, before `super`. If you use a custom `AppDelegate` that doesn't extend `ExponeaFlutterAppDelegate`, call `SwiftExponeaPlugin.setUserNotificationCenterDelegate(_:)` at the start of `application(_:didFinishLaunchingWithOptions:)` instead.
- Add `FlutterImplicitEngineDelegate` conformance to your `AppDelegate` and move `GeneratedPluginRegistrant.register` to `didInitializeImplicitFlutterEngine`.
- Remove any `GeneratedPluginRegistrant.register(with: self)` call from `application(_:didFinishLaunchingWithOptions:)`.
- Add a `UIApplicationSceneManifest` entry to your `Info.plist` with `UISceneDelegateClassName` set to `FlutterSceneDelegate`.

For Universal Links only: if you use `ExponeaFlutterAppDelegate`, no further SDK-specific changes are required — the SDK tracks Universal Links under the UIScene lifecycle automatically via `FlutterSceneLifeCycleDelegate`. If you use a fully custom `AppDelegate` / `SceneDelegate` that doesn't extend `ExponeaFlutterAppDelegate` or forward Flutter scene lifecycle events, refer to the [Universal Links documentation](app-links.md) for manual forwarding instructions.

### 3. New configuration and auth APIs (optional migration)

Existing **Project** integrations continue to work without code changes. Legacy flat configuration fields (`projectToken`, `authorizationToken`, `baseUrl`, `projectMapping`) still work but emit deprecation warnings.

To adopt the new API surface (recommended for new Stream integrations):

| Legacy | Preferred |
| ------ | --------- |
| Flat `projectToken` / `authorizationToken` / `baseUrl` | `integrationConfig: ProjectIntegrationConfig(...)` |
| `projectMapping` | `integrationRouteMap` with `ProjectIntegrationConfig` |
| `ExponeaConfigurationChange` in `anonymize()` | `IntegrationConfigurationChange` |
| `Customer` only in `identifyCustomer()` | `CustomerIdentity` for Stream mode with JWT |

For **Stream mode**, see [Configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration#integration-modes), [SDK auth token authorization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization#sdk-auth-token-authorization), and [Initialize with customer identity](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#initialize-with-customer-identity).

## Update to version 2.3.0 or higher

SDK versions 2.3.0 and higher support multiple mobile applications within a single {user.mkg} project.

This update introduces two major changes:

### 1. **Application ID configuration**

Each mobile application integrated with the SDK can now have its own unique `applicationId`. This identifier distinguishes between different applications within the same project.

**When to configure Application ID:**

- **Multiple mobile apps:** You must specify a unique `applicationId` for each app in the SDK configuration. The value must match the Application ID configured in {user.mkg} under **Project Settings > Campaigns > Channels > Push Notifications.**
- **Single mobile app:** If you use only one mobile application, you don't need to set `applicationId`. The SDK uses the default value `default-application` automatically.

Learn more about [Configuration for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration) and [Initial setup for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#configure-application-id).

## Update from version 1.x.x to 2.x.x

Updating the Exponea Flutter SDK to version 2.X.X from 1.X.X requires making some changes related to in-app messages Action Stream implementations.

The inAppMessageActionStream was changed and simplified, so you have to migrate your implementation of in-app message action and close handling. This migration requires changing decision logic based on parameters coming from the stream.

Your implementation may have been similar to the following example:

```dart
const overrideDefaultBehavior = false;
const trackActions = false;
final subscription = _plugin.inAppMessageActionStream(overrideDefaultBehavior: overrideDefaultBehavior, trackActions: trackActions).listen((inAppMessageAction) {
  if (inAppMessageAction.button != null) {  
      _plugin.trackInAppMessageClick(inAppMessageAction.message, inAppMessageAction.button);
  } else {
      _plugin.trackInAppMessageClose(inAppMessageAction.message, interaction: inAppMessageAction.interaction);
  }
});
```

To update to version 2 of the SDK, you must recognize the inAppMessageAction event by its `type` parameter and refactor your code as follows:

```dart
const overrideDefaultBehavior = false;
const trackActions = false;
final subscription = _plugin.inAppMessageActionStream(overrideDefaultBehavior: overrideDefaultBehavior, trackActions: trackActions).listen((inAppMessageAction) {
  if (<your-special-condition>) {
    switch(inAppMessageAction.type) {
      case InAppMessageActionType.click:
        _plugin.trackInAppMessageClick(inAppMessageAction.message!, inAppMessageAction.button!);
        break;
      case InAppMessageActionType.close:
        _plugin.trackInAppMessageClose(inAppMessageAction.message!, button: inAppMessageAction.button, interaction: inAppMessageAction.interaction ?? true);
        break;
      case InAppMessageActionType.error:
        // Here goes your code
        break;
      case InAppMessageActionType.show:
        // Here goes your code
        break;
    }
  }
});
```

A benefit of the new behavior is that the method inAppMessageCloseAction can be called with a non-null button parameter. This happens when a user clicks on the Cancel button and enables you to determine which button has been clicked by reading the button text.

### inAppMessageAction scheme change

inAppMessageActionStream also emits Show and Error events. You can distinguish events by introduced `type` parameter in `inAppMessageAction`.
As not all values are reported for each type, `interaction` and `InAppMessage` in scheme become nullable.

## Update from version 0.x.x to 1.x.x

Updating the Exponea Flutter SDK to version 1 and higher requires making some changes related to Firebase push notifications.

### Changes regarding FirebaseMessagingService

We decided not to include the implementation of FirebaseMessagingService in our SDK since we want to keep it as small as possible and avoid including libraries that are not essential for its functionality. The SDK no longer has a dependency on the firebase library. You will need to make the following changes:

1. You must implement `FirebaseMessagingService` on your Android application side.
2. Call `ExponeaPlugin.handleRemoteMessage` when a message is received.
3. Call `ExponeaPlugin.handleNewGmsToken` when a token is obtained.
4. Register this service in your `AndroidManifest.xml`.

```kotlin
import android.app.NotificationManager
import android.content.Context
import com.exponea.ExponeaPlugin
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MessageService : FirebaseMessagingService() {
    private val notificationManager by lazy {
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        ExponeaPlugin.handleRemoteMessage(applicationContext, message.data, notificationManager)
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        ExponeaPlugin.handleNewGmsToken(applicationContext, token)
    }
}
```

```xml
...
<application>  
     <service android:name=".MessageService" android:exported="false" >  
         <intent-filter> 
             <action android:name="com.google.firebase.MESSAGING_EVENT" />  
         </intent-filter> 
     </service>
</application>
 ...
```
