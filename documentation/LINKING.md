# Tracking Campaigns (Android App Links/Universal links)
The official [Flutter documentation](https://flutter.dev/docs/development/ui/navigation/deep-linking) describes how to set up your application and how to process incoming link, we just need to add tracking to Exponea.
> When the application is opened by App Link/Universal link and there is no session active, started session will contain tracking parameters from the link.

WARNING: The official deep-linking support in flutter sdk does not currently work properly for iOS. 
(Github issue: https://github.com/flutter/flutter/issues/82550)
If the issue is still not fixed in your flutter version, then usage of flutter plugin [uni_links](https://pub.dev/packages/uni_links) is recommended.
See exponea example app code and [installation steps](https://pub.dev/packages/uni_links) for more info. 

## Android
Android linking works automagically without any changes required. To enable Exponea tracking you need to add 2 methods to the `MainActivity` that will respond to incoming intents.
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

## iOS
Linking requires you to call `SwiftExponeaPlugin.continueUserActivity(userActivity)` function in your `AppDelegate`.

### With ExponeaFlutterAppDelegate
If your `AppDelegate` already extends `ExponeaFlutterAppDelegate` no change is required.


### Without ExponeaFlutterAppDelegate
If you don't use the `ExponeaFlutterAppDelegate`, you need to implement the method and call `SwiftExponeaPlugin`.
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
