---
title: Configuration
excerpt: Full configuration reference for the Flutter SDK
slug: flutter-sdk-configuration
categorySlug: integrations
parentDocSlug: flutter-sdk-setup
---

This page provides an overview of all configuration parameters for the SDK. In addition to the universal parameters, there are Android-specific and iOS-specific parameters.

> 📘
>
> Refer to [Initialize the SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#initialize-the-sdk) for instructions.

## Configuration parameters

The following parameters are specified in an `ExponeaConfiguration` object. Refer to [lib/src/data/model/configuration.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/lib/src/data/model/configuration.dart) for the complete Dart definition.

* `projectToken` **(required)**
   * Your project token. You can find this in the Engagement web app under `Project settings` > `Access management` > `API`.

* `authorization` **(required)**
   * Your Engagement API key.
   * The token must be an Engagement **public** key. See [Mobile SDKs API Access Management](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management) for details.
   * For more information, refer to [Exponea API documentation](https://docs.exponea.com/reference#access-keys).

* `baseURL`
  * Your API base URL which can be found in the Engagement web app under `Project settings` > `Access management` > `API`.
  * Default value `https://api.exponea.com`.
  * If you have custom base URL, you must set this property.

* `projectMapping`
  * If you need to track some events to a different Engagement project, you can define a mapping between event types and Engagement projects.
  * An event is always tracked to the default project and any projects it is mapped to.
  * Example:
    ```dart
    projectMapping: {
      EventType.banner: [
        ExponeaProject(
          projectToken: 'other-project-token',
          authorizationToken: 'other-auth-token',
        ),
      ],
    }
    ```
  
* `defaultProperties`
  * A list of properties to include in all tracking events.
  * You can change these properties at runtime by calling `ExponeaPlugin().setDefaultProperties()`.
  * You can also override default session event properties. For example, if you don't want to track the customer's IP address, you can include the property `ip` with an empty string value.

* `automaticSessionTracking`
  * Flag to control the automatic tracking of `session_start` and `session_end` events.
  * Default value: `true`

* `sessionTimeout`
  * The session is the actual time spent in the app. It starts when the app is launched and ends when the app goes into the background.
  * When the application goes into the background, the SDK doesn't track the end of the session right away but waits a bit for the user to come back before doing so. You can configure the timeout by setting this property.
  * Read more about [Tracking Sessions](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking#session)

* `pushTokenTrackingFrequency`
  * Indicates the frequency with which the SDK should track the push notification token to Engagement.
  * Default value: `TokenFrequency.onTokenChange`
  * Possible values:
    * `.onTokenChange` - tracks push token if it differs from a previously tracked one
    * `.everyLaunch` - always tracks push token
    * `.daily` - tracks push token once per day

* `flushMaxRetries`
  * Controls how many times the SDK should attempt to flush an event before aborting. Useful for example in case the API is down or some other temporary error happens.
  * The SDK will consider the data to be flushed if this number is exceeded and delete the data from the queue.
  * Default value: `10`

* `advancedAuthEnabled`
  * If set, advanced authorization is used for communication with the Engagement APIs listed in [Customer Token Authorization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization#customer-token-authorization).
  * Refer to the [authorization documentation](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization) for details.

* `inAppContentBlockPlaceholdersAutoLoad`
  * Automatically load the contents of in-app content blocks assigned to these Placeholder IDs.

* `android`
  * `AndroidExponeaConfiguration` object containing [Android-specific configuration parameters](#android-specific-configuration-parameters).

* `ios`
  * `IOSExponeaConfiguration` object containing [iOS-specific configuration parameters](#ios-specific-configuration-parameters).

### Android-specific configuration parameters

The following parameters are specified in an `AndroidExponeaConfiguration` object. Refer to [lib/src/data/model/configuration.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/lib/src/data/model/configuration.dart) for the complete Dart definition

* `automaticPushNotifications`
  * By default, the SDK will set up a Firebase service and try to process push notifications sent from the Engagement platform automatically. You can opt out by setting this to `false`.
  * Default value: `true`

* `pushIcon`
  * Android resource ID of the icon to be used for push notifications.

* `pushAccentColor`
  * Accent color of push notification icon and buttons.

* `pushChannelName`
  * Name of the channel to be created for the push notifications.
  * Only available for API level 26+. Refer to https://developer.android.com/training/notify-user/channels for details.

* `pushChannelDescription`
  * Description of the channel to be created for the push notifications.
  * Only available for API level 26+. Refer to https://developer.android.com/training/notify-user/channels for details.

* `pushChannelId`
  * Channel ID for push notifications.
  * Only available for API level 26+. Refer to https://developer.android.com/training/notify-user/channels for details.

* `pushNotificationImportance`
  * Notification importance for the notification channel.
  * Only available for API level 26+. Refer to https://developer.android.com/training/notify-user/channels for details.

* `httpLoggingLevel`
  * Level of HTTP request/response logging.

### iOS-specific configuration parameters

The following parameters are specified in an `IOSExponeaConfiguration` object. Refer to [lib/src/data/model/configuration.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/lib/src/data/model/configuration.dart) for the complete Dart definition

* `requirePushAuthorization`
  * The SDK can check push notification authorization status ([Apple documentation](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus)) and only track the push token if the user is authorized to receive push notifications.
  * When disabled, the SDK will automatically register for push notifications on app start and track the token to Engagement so your app can receive silent push notifications.
  * When enabled, the SDK will automatically register for push notifications if the app is authorized to show push notifications to the user.
  * Unless you're only using silent notifications, keep the default value `true`.

* `appGroup`
  * App group used for communication between the main app and notification extensions. This is a required field for rich push notification setup.