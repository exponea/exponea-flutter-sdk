---
title: Push Notifications
excerpt: Enable push notifications in your app using the Flutter SDK
slug: flutter-sdk-push-notifications
categorySlug: integrations
parentDocSlug: flutter-sdk
---

Engagement enables sending push notifications to your app users using [scenarios](https://documentation.bloomreach.com/engagement/docs/scenarios-1). The mobile application handles the push message using the SDK and renders the notification on the customer's device.

Push notifications can also be silent, used only to update the app’s interface or trigger some background task.

> 📘
>
> Refer to [Mobile Push Notifications](https://documentation.bloomreach.com/engagement/docs/mobile-push-notifications#creating-a-new-notification) to learn how to create push notifications in the Engagement web app.

## Integration

The Flutter SDK relies on the underlying native Android and iOS platforms to handle push notifications.

The following pages describe the steps for each platform to add the minimum push notification functionality (receive alert notifications) to your app.

- [Android Push Notifications](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-android)
- [iOS Push Notifications](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-ios)

## Customization

This section describes the customizations you can implement once you have integrated the minimum push notification functionality.

### Configure Automatic Push Notification Tracking

By default, the SDK tracks push notifications automatically. In the [SDK configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration), you can set the desired frequency using the `pushTokenTrackingFrequency` property (default value is `TokenFrequency.onTokenChange`). You can also disable automatic push notification tracking by setting the Boolean value of the `automaticPushNotifications` property to `false`.

If `automaticPushNotifications` is enabled, the SDK will display push notifications from Engagement and track a "campaign" event for every delivered/opened push notification with the relevant properties.

### Respond to Push Notification Interactions

Once you have followed the integration steps for each platform, your app should be able to receive push notifications.

To respond to a push notification interaction, you can set up a listener to `ExponeaPlugin().openedPushStream`:

```dart
import 'package:exponea/exponea.dart';

final _plugin = ExponeaPlugin();
final subscription = _plugin.openedPushStream.listen((openedPush) {
  switch(openedPush.action) {
    case PushActionType.app:
      // last push directed user to your app with no link

      // log data defined on Exponea backend
      print('app - ${openedPush.data}'); 
      break;
    case PushActionType.deeplink:
      // last push directed user to your app with deeplink
      print('deeplink - ${openedPush.url}');
      break;
    case PushActionType.web:
      // last push directed user to web, nothing to do here
      print('web');
      break;
  }
});
```

Call `subscription.cancel()` when you no longer need the listener.

We recommend registering the listener as soon as possible to ensure proper application flow. However, the SDK will hold the last push notification and call the listener once it's registered.

> ❗️
>
> To support deep links, additional set up steps are required. Refer to the documentation for the respective native platforms ([Android](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-android), [iOS](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-ios)). Alternatively, use the `Open app` action instead and add your payload to `Additional data`.


### Respond to Received Push Notifications

You can set up a listener for received push notifications using `ExponeaPlugin.receivedPushStream`, which is especially useful for silent push notifications.

```dart
final subscription = _plugin.receivedPushStream.listen((receivedPush) {
  print(receivedPush);
});
```

Call `subscription.cancel()` when you no longer need the listener.

We recommend registering the listener as soon as possible to ensure proper application flow. However, the SDK will hold the last push notification and call the listener once it's registered.

> ❗️
>
> The listener is called for both regular and silent push notifications on Android but **only** for silent push notifications on iOS due to technical limitations.

### Manually Track Push Notifications

If you disable [automatic push notification tracking](#configure-automatic-push-notification-tracking) or if you want to track push notification from other providers, you can manually track events related to push notifications.

#### Track Push Token (FCM)

Use the `trackPushToken` method to manually track the FCM push token:

```dart
ExponeaPlugin().trackPushToken("382d4221-3441-44b7-a676-3eb5f515157f")
```

Invoking this method will track the push token immediately regardless of the [SDK configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration) for `tokenTrackFrequency`.

#### Track Delivered Push Notification

Use the `trackDeliveredPush` method to manually track a delivered push notification:

```dart
final Map<String, dynamic> payload = {
  "platform": "android",
  "subject": "subject",
  "type": "push",
  "url_params": {
    "utm_campaign": "Campaign name",
    "utm_medium": "mobile_push_notification",
    "utm_content": "en",
    ...
  },
  ...
};
ExponeaPlugin().trackDeliveredPush(payload)
```

> ❗️
>
> The behaviour of `trackDeliveredPush` may be affected by the tracking consent feature, which, when enabled, requires explicit consent for tracking. Read more in the [tracking consent documentation](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking-consent).

#### Track Clicked Push Notification

Use the `trackClickedPush` method to manually track a clicked push notification:

```dart
final Map<String, dynamic> payload = {
  "platform": "android",
  "subject": "subject",
  "type": "push",
  "url_params": {
    "utm_campaign": "Campaign name",
    "utm_medium": "mobile_push_notification",
    "utm_content": "en",
    ...
  },
  ...
};
ExponeaPlugin().trackClickedPush(payload)
```

> The behaviour of `trackClickedPush` may be affected by the tracking consent feature, which, when enabled, requires explicit consent for tracking. Read more in the [tracking consent documentation](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking-consent).

### Custom Push Notification Data Processing

If the provided native `ExponeaModule.Companion.handleRemoteMessage` (Android) and `ExponeaNotificationService().process` (iOS)  methods don't fit the requirements of your app, or you decide to disable automatic push notifications, you must handle push notifications and process their payload yourself.

Notification payloads are generated from (possibly complex) scenarios in the Engagement platform and contain all data for Android, iOS and web platforms. Therefore, the payload itself can be complex.

Notification payloads use a JSON data structure.

#### Payload Example

```json
{
    "notification_id": 123,
    "url": "https://example.com/main_action",
    "title": "Notification title",
    "action": "app|browser|deeplink|self-check",
    "message": "Notification message",
    "image": "https://example.com/image.jpg",
    "actions": [
        {"title": "Action 1", "action": "app|browser|deeplink", "url": "https://example.com/action1"}
    ],
    "sound": "default",
    "aps": {
        "alert": {"title": "Notification title", "body": "Notification message"},
        "mutable-content": 1
    },
    "attributes": {
        "event_type": "campaign",
        "campaign_id": "123456",
        "campaign_name": "Campaign name",
        "action_id": 1,
        "action_type": "mobile notification",
        "action_name": "Action 1",
        "campaign_policy": "policy",
        "consent_category": "General consent",
        "subject": "Subject",
        "language": "en",
        "platform": "ios|android",
        "sent_timestamp": 1631234567.89,
        "recipient": "user@example.com"
    },
    "url_params": {"param1": "value1", "param2": "value2"},
    "source": "xnpe_platform",
    "silent": false,
    "has_tracking_consent": true,
    "consent_category_tracking": "Tracking consent name"
}
```