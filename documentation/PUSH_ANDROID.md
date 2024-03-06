# Android Push notification setup
We rely on our native SDK to do push tracking. For more complex scenarios(multiple push providers) please can check [native Android SDK Push notification documentation](https://github.com/exponea/exponea-android-sdk/blob/develop/Documentation/PUSH.md).

> Exponea Android SDK contains self-check functionality to help you successfully setup push notifications. Self-check will try to track push token, request Exponea backend to send silent push to the device and check the app is ready to open push notifications. To enable self-check call `ExponeaPlugin().checkPushSetup()` **before** configuring the SDK.

> The behaviour of Push delivery and click tracking may be affected by the tracking consent feature, which in enabled mode considers the requirement of explicit consent for tracking. Read more in [tracking consent documentation](https://github.com/exponea/exponea-android-sdk/blob/develop/Documentation/TRACKING_CONSENT.md).

## Push Integrations
Exponea Android SDK supports these integrations:

- [Standard (Firebase) integration](#firebase-integration)
- [Huawei integration](#huawei-integration)

## Firebase integration 

### Integrating Firebase into your project
To send/receive push notifications, you have to set up the Firebase project. [Official Firebase documentation](https://firebase.google.com/docs/android/setup#console) describes this process. You'll need to create a project in the Firebase console, add generated `google-services.json` to your app and update Gradle scripts.

> When following the Firebase documentation, the root of your Android project is `/android`.

#### Checklist:
 - `google-services.json` file downloaded from the Firebase console is in the **android/app** folder of your Android project e.g., *android/app/google-services.json*
 - your **android/app** folder gradle build file(*android/app/build.gradle*) contains `apply plugin: 'com.google.gms.google-services'`
 - your **android** folder gradle build file(*android/build.gradle*) has `classpath 'com.google.gms:google-services:X.X.X'` listed in build script dependencies.

### Passing token and messages to Exponea SDK
To handle incomming push messages, you will have to create your `FirebaseMessagingService` implementation and register it in your `AndroidManifest.xml`. Then, call `handleRemoteMessage` in `onMessageReceived` method and `handleNewGmsToken` in `onNewToken` method, like in example code below:

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

Registering in AndroidManifest.xml
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
 
### Setting the Firebase server key in the Exponea web app
You'll need to set the Firebase server key so Exponea can use it to send push notifications to your application. Our native Android has a [guide describing how to do so](https://github.com/exponea/exponea-android-sdk/blob/develop/Guides/FIREBASE.md).

### That's it
After these steps, you should be able to receive push notifications from Exponea. To learn how to send one, check a [Sending Push notifications guide](./PUSH_SEND.md).

> **Quick Tip:** If you are integrating Exponea SDK to existing project, you may face an issue that your 'HmsMessageService' is not called automatically.
> To retrieve a fresh Push token, you should consider to request a token manually as soon as possible after application start init.
> Please read a HMS guide how to retrieve current Push token https://developer.huawei.com/consumer/en/doc/development/HMSCore-Guides/android-client-dev-0000001050042041

## Huawei integration
Newer phones manufactured by [Huawei](https://huaweimobileservices.com/) come with Huawei Mobile Services (HMS). It's a service used to deliver push _instead of_ Google's Firebase Cloud Messaging (FCM).

### Integrating HMS into your project
To send/receive push notifications, you have to:
1. register and set up a [Huawei Developer account](https://developer.huawei.com/consumer/en/console)
2. create a project and App in AppGallery Connect
3. generate and configure a Signing Certificate
4. enable push kit in AppGallery Connect APIs
5. update Gradle scripts and add generated `agconnect-services.json` to your app
6. configure the Signing Information in your app

Steps 2-6 are described in detail in the official [Huawei documentation](https://developer.huawei.com/consumer/en/codelab/HMSPreparation/index.html#0)

### Passing token and messages to Exponea SDK
To handle incomming push messages, you will have to create your `HmsMessageService` implementation and register it in your `AndroidManifest.xml`. Then, call `handleRemoteMessage` in `onMessageReceived` method and `handleNewHmsToken` in `onNewToken` method, like in example code below:

```kotlin
import android.app.NotificationManager
import android.content.Context
import com.exponea.ExponeaPlugin
import com.huawei.hms.push.HmsMessageService
import com.huawei.hms.push.RemoteMessage

class MessageService : HmsMessageService() {

    private val notificationManager by lazy {
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        ExponeaPlugin.handleRemoteMessage(applicationContext, message.dataOfMap, notificationManager)
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        ExponeaPlugin.handleNewHmsToken(applicationContext, token)
    }
}
```
Registering in AndroidManifest.xml
```xml
...
<application>  
   <service android:name=".MessageService" android:exported="false">  
     <intent-filter> 
       <action android:name="com.huawei.push.action.MESSAGING_EVENT"/>  
     </intent-filter> 
   </service> 
   <meta-data  android:name="push_kit_auto_init_enabled"  android:value="true"/>  
</application>
 ...
```

### That's it
After these steps, you should be able to receive push notifications from Exponea. To learn how to send one, check a [Sending Push notifications guide](./PUSH_SEND.md).

## Deeplinking
You can use `ExponeaPlugin().openedPushStream` to define a listener that will respond to push notifications. If you'd like to use deep-linking, you'll need to update your `AndroidManifest` in `android/src/main` a bit.

### Set activity to single task launch mode
By default, Android will launch a new activity for your application when a deep-link is opened. You want to override this by setting `android:launchMode="singleTask"` for your main activity.
``` xml
<activity
  android:name=".MainActivity"
  ...
  android:launchMode="singleTask"
>
```

### Define an intent filter
You'll have to define an intent filter that can respond to URL you define when creating a push notification. You can either use a custom scheme or an URL. You can find more information in the official [Android documentation](https://developer.android.com/training/app-links/deep-linking#adding-filters).

```xml
<activity ...>
   ...
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

      <!-- Accepts URIs that begin with "exponea://action”-->
      <data android:scheme="exponea" android:host="action" />

      <!-- Accepts URIs that begin https://www.example.com -->
      <data android:scheme="https" android:host="www.example.com" />
  </intent-filter>
</activity>
```

### Show notification if app is in foreground
When app is in foreground, notifications are not shown, they end up in notification drawer and notification icon is shown in status bar. To achieve showing notification when app is in foreground, you can can set up a listener for received push notifications using `ExponeaPlugin.receivedPushStream` and implement showing of notification via third party plugin as flutter_local_notifications.
> The listener is called for both regular and silent push notifications on Android and **only** for silent push notifications on iOS due to technical limitations.

```dart
final subscription = _plugin.receivedPushStream.listen((receivedPush) {
  _showPushNotification(receivedPush);
});
```
Don't forget to call `subscription.cancel()` when no longer needed.

## Notification permission
Android 13 (API level 33) introduces a new runtime notification permission that is needed to be registered in your AndroidManifest.xml and also allowed by user, otherwise your application would not be able to show push notifications.
First step (register `POST_NOTIFICATIONS` permission) is already registered by SDK.
Second step (show runtime permission dialog) has to be triggered from your application. You may use SDK API for that purpose:

```dart 
_plugin.requestPushAuthorization()
.then((accepted) => print("User has ${accepted ? 'accepted': 'rejected'} push notifications."))
.catchError((error) => print('Error: $error'));
```

SDK will show a simple dialog for user to allow or deny `POST_NOTIFICATIONS` permission. Although this permission request is not needed for previous Android version, you are free to invoke this method anyway. Callback value `granted` is returned TRUE for older Android systems.
Behavior if this callback is:
* For Android older that 33
  * you don't need permission, TRUE is returned automatically
* For Android newer, 33+
  * dialog prompt (from system) is shown do decide, decision is returned (true/false)
  * for already given permission - dialog is not shown and TRUE is returned

## Troubleshooting
In case of push notifications not working for you, these are frequent issues with the most likely solutions.

### Push notifications do not open the app after clicking on the notification on Xiaomi Redmi devices

Xiaomi MIUI is handling battery optimization in its own way and can sometimes affect the behavior of push notifications. 
If battery optimization is on for devices with MIUI, it can make push notifications stop showing or not working after the click. Unfortunately, there is nothing we can do on our end to prevent this, but you can try this to solve the issues:

-   Turn off any battery optimizations in Settings->Battery & Performance you can
-   Set the "No restrictions" option in battery saver options for your app
-   And (probably) most important, turn off Memory and MIUI Optimization under Developer Options

### Push notification token is missing after anonymization

There is principal usage of `ExponeaPlugin().anonymize()` as a sign-out feature in some applications. Keep in mind that invoking of `anonymize` will remove also a Push notification token from storage. To load a current token, your application should retrieve a valid token manually before using any Push notification feature. So it may be called right after `anonymize` or before/after `identifyCustomer`, it depends on your Push notifications usage.

```kotlin
import android.os.Bundle
import com.exponea.ExponeaPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FirebaseMessaging.getInstance().token.addOnSuccessListener {
            ExponeaPlugin.handleNewGmsToken(applicationContext, it)
        }
    }
}
```
