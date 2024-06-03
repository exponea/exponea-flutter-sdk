---
title: SDK Version Update Guide
excerpt: Update Exponea Flutter SDK in your app to a new version
slug: flutter-sdk-version-update
categorySlug: integrations
parentDocSlug: flutter-sdk-release-notes
---

This guide will help you upgrade your Exponea SDK to the new version.

## Update From Version 0.x.x to 1.x.x

Updating the Exponea Flutter SDK to version 1 and higher requires making some changes related to Firebase push notifications.

### Changes Regarding FirebaseMessagingService

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