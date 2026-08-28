---
title: Links for Flutter SDK
slug: flutter-sdk-links
category:
  uri: /branches/2/categories/guides/Developers
parent:
  uri: flutter-sdk
content:
  excerpt: >-
    Enable and track Android App Links and iOS Universal Links in your app using
    the Flutter SDK
---

Android App Links and iOS Universal Links allow the links you send through {user.mkg} to open directly in your mobile application without any redirects that would hinder your users' experience.

For details on how App Links and Universal Links work and how they can improve your users' experience, refer to the [Universal Links](https://documentation.bloomreach.com/engagement/docs/universal-link) section in the Campaigns documentation.

This page describes the steps required to support and track incoming App Links and Universal Links in your app using the Flutter SDK.

## Implement and track App Links and Universal Links

The official [Flutter documentation](https://docs.flutter.dev/ui/navigation/deep-linking) describes how to set up your application and how to process incoming links. , we just need to add tracking to Exponea.

> 👍
>
> When the application is opened by an App Link or Universal link while there is no session active, the newly started session will contain tracking parameters from the link.


### Android

No changes are required to make App Links work.

To track the links to {user.mkg}, you must add 2 methods to the `MainActivity` that will respond to incoming intents:

```kotlin
package com.exponea.example

import android.content.Intent
import android.os.Bundle
import com.exponea.ExponeaPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Add this call:
        ExponeaPlugin.Companion.handleCampaignIntent(intent, applicationContext)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        // Add this call:
        ExponeaPlugin.Companion.handleCampaignIntent(intent, applicationContext)
        super.onNewIntent(intent)
    }
}
```

### iOS

Universal Links are handled automatically by the SDK for both the legacy `AppDelegate` lifecycle and the `UIScene` lifecycle (Flutter 3.38+).

#### With ExponeaFlutterAppDelegate

If your `AppDelegate` extends `ExponeaFlutterAppDelegate`, no changes are required — Universal Links are tracked automatically in both lifecycle modes.

#### Without ExponeaFlutterAppDelegate

**Legacy lifecycle** — if your `AppDelegate` doesn't extend `ExponeaFlutterAppDelegate`, forward the event manually (the plugin doesn't implement `application(_:continue:restorationHandler:)` to avoid double-firing alongside `ExponeaFlutterAppDelegate`).

If your `AppDelegate` still extends `FlutterAppDelegate`, track then call `super` so Flutter can still handle deeplinking (don't return `true` without calling `super` — that claims the activity and can skip Flutter's link handling):
```swift
override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
) -> Bool {
    SwiftExponeaPlugin.continueUserActivity(userActivity)
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
}
```

If you implement `UIApplicationDelegate` directly (no `FlutterAppDelegate`), call `SwiftExponeaPlugin.continueUserActivity(userActivity)` and return whatever your own routing logic requires.

**UIScene lifecycle** (Flutter 3.38+):

If you use the standard migration (`FlutterSceneDelegate` declared in `Info.plist`), no manual implementation is required — the SDK registers itself via `addSceneDelegate` and tracks Universal Links automatically for both cold launch and warm launch.

If you use the `FlutterSceneLifeCycleProvider` protocol and correctly forward scene callbacks to your `FlutterPluginSceneLifeCycleDelegate`, no manual forwarding is required — `addSceneDelegate` routes events to the SDK automatically.

If you use a fully custom `SceneDelegate` that **doesn't** subclass `FlutterSceneDelegate` and **doesn't** forward Flutter scene lifecycle events to a `FlutterPluginSceneLifeCycleDelegate`, you must forward both the cold launch and warm launch events manually:
```swift
func scene(_ scene: UIScene,
           willConnectTo session: UISceneSession,
           options connectionOptions: UIScene.ConnectionOptions) {
    if let userActivity = connectionOptions.userActivities
        .first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }) {
        SwiftExponeaPlugin.continueUserActivity(userActivity)
    }
}

func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    SwiftExponeaPlugin.continueUserActivity(userActivity)
}
```
