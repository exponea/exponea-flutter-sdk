---
title: Links
excerpt: Enable and track Android App Links and iOS Universal Links in your app using the Flutter SDK
slug: flutter-sdk-links
categorySlug: integrations
parentDocSlug: flutter-sdk
---

Android App Links and iOS Universal Links allow the links you send through Engagement to open directly in your mobile application without any redirects that would hinder your users' experience.

For details on how App Links and Universal Links work and how they can improve your users' experience, refer to the [Universal Links](https://documentation.bloomreach.com/engagement/docs/universal-link) section in the Campaigns documentation.

This page describes the steps required to support and track incoming App Links and Universal Links in your app using the Flutter SDK.

## Implement and track App Links and Universal Links

The official [Flutter documentation](https://docs.flutter.dev/ui/navigation/deep-linking) describes how to set up your application and how to process incoming links. , we just need to add tracking to Exponea.

> 👍
>
> When the application is opened by an App Link or Universal link while there is no session active, the newly started session will contain tracking parameters from the link.


### Android

No changes are required to make App Links work.

To track the links to Engagement, you must add 2 methods to the `MainActivity` that will respond to incoming intents:

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

Your `AppDelegate` must call `SwiftExponeaPlugin.continueUserActivity(userActivity)` to make Universal Links work.

#### With ExponeaFlutterAppDelegate

If your `AppDelegate` already extends `ExponeaFlutterAppDelegate`, no change is required.

#### Without ExponeaFlutterAppDelegate

If you don't use the `ExponeaFlutterAppDelegate`, you must implement the method and call `SwiftExponeaPlugin`:

```swift
    open override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        SwiftExponeaPlugin.continueUserActivity(userActivity)
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
```
