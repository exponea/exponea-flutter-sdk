---
title: SDK version update guide
excerpt: Update Exponea Flutter SDK in your app to a new version
slug: flutter-sdk-version-update
categorySlug: integrations
parentDocSlug: flutter-sdk-release-notes
---

This guide will help you upgrade your Exponea SDK to the new version.

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