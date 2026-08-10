---
title: Configuration for Flutter SDK
slug: flutter-sdk-configuration
category:
  uri: /branches/2/categories/guides/Developers
parent:
  uri: flutter-sdk-setup
content:
  excerpt: Full configuration reference for the Flutter SDK
---

This page provides an overview of all configuration parameters for the SDK. In addition to the universal parameters, there are Android-specific and iOS-specific parameters.

> 📘
>
> Refer to [Initialize the SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#initialize-the-sdk) for instructions.

## Configuration parameters

The following parameters are specified in an `ExponeaConfiguration` object. Refer to [lib/src/data/model/configuration.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/lib/src/data/model/configuration.dart) for the complete Dart definition.

* `projectToken` **(required)**
   * Your project token. You can find this in the {user.mkg} web app under `Project settings` > `Access management` > `API`.

* `authorizationToken` **(required)**
   * Your {user.mkg} API key.
   * The token must be an {user.mkg} **public** key. See [Mobile SDKs API Access Management](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management) for details.
   * For more information, refer to [Exponea API documentation](https://docs.exponea.com/reference#access-keys).

* `baseUrl`
  * Your API base URL which can be found in the {user.mkg} web app under `Project settings` > `Access management` > `API`.
  * Default value `https://api.exponea.com`.
  * If you have custom base URL, you must set this property.

* `projectMapping`
  * If you need to track some events to a different {user.mkg} project, you can define a mapping between event types and {user.mkg} projects.
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

* `allowDefaultCustomerProperties`
  * Flag to apply `defaultProperties` list to `identifyCustomer` tracking event
  * Default value: `true`

* `automaticSessionTracking`
  * Flag to control the automatic tracking of `session_start` and `session_end` events.
  * Default value: `true`

* `sessionTimeout`
  * The session is the actual time spent in the app. It starts when the app is launched and ends when the app goes into the background.
  * When the application goes into the background, the SDK doesn't track the end of the session right away but waits a bit for the user to come back before doing so. You can configure the timeout by setting this property.
  * Read more about [Tracking Sessions](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking#session)

* `pushTokenTrackingFrequency`
  * Indicates the frequency with which the SDK should track the push notification token to {user.mkg}.
  * Default value: `TokenFrequency.onTokenChange`
  * Possible values:
    * `.onTokenChange` - tracks the push token if it differs from a previously tracked one. The SDK also automatically refreshes the `notification_state` event every 30 days, even when the token hasn't changed.
    * `.everyLaunch` - tracks the push token once per app launch (process start). Some operations always trigger tracking regardless of this setting: calling `trackPushToken()` manually, receiving a new token from FCM, HMS, or APNs, and calling `anonymize()` or `stopIntegration()`.
    * `.daily` - tracks push token once per day

* `requirePushAuthorization` **(deprecated — use iOS-specific `ios.requirePushAuthorization` instead)**
  * **Android:** This property has no effect. The SDK always tracks the push token regardless of this flag.
  * **iOS:** Kept for backward compatibility. When you set both the top-level and `ios.requirePushAuthorization` values, the iOS-specific value takes precedence.
  * For more details, see [iOS-specific configuration parameters](#ios-specific-configuration-parameters).

* `flushMaxRetries`
  * Controls how many times the SDK should attempt to flush an event before aborting. Useful for example in case the API is down or some other temporary error happens.
  * The SDK will consider the data to be flushed if this number is exceeded and delete the data from the queue.
  * Default value: `10`

* `advancedAuthEnabled`
  * If set, advanced authorization is used for communication with the {user.mkg} APIs listed in [Customer Token Authorization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization#customer-token-authorization).
  * Refer to the [authorization documentation](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization) for details.

* `inAppContentBlockPlaceholdersAutoLoad`
  * Automatically load the contents of in-app content blocks assigned to these Placeholder IDs.

* `manualSessionAutoClose`
  * Determines whether the SDK automatically tracks `session_end` for sessions that remain open when `ExponeaPlugin().trackSessionStart()` is called multiple times in manual session tracking mode.
  * Default value: `true`

* `regenerateDeviceIdOnAnonymize`
  * If `true`, calling `ExponeaPlugin().anonymize()` generates a new `device_id` for the new anonymous customer profile, so the device identifier no longer links the new profile to the previous customer's events.
  * Set this to `true` when your privacy requirements include a sign-out flow that produces two unlinkable customer profiles. The default (`false`) preserves the existing behavior where `device_id` persists across `anonymize()` calls.
  * Default value: `false`

* `applicationId`
  * This `applicationId` defines a unique identifier for the mobile app within the {user.mkg} project. Change this value only if your {user.mkg} project contains and supports multiple mobile apps.
  * This identifier distinguishes between different apps in the same project.
  * Your `applicationId` value must be the same as the one defined in your {user.mkg} project settings.
  * If your {user.mkg} project supports only one app, skip the `applicationId` configuration. The SDK will use the default value automatically.
  * Must be in a specific format, see rules:
    * Starts with one or more lowercase letters or digits
    * Additional words are separated by single hyphens or dots
    * No leading or trailing hyphens or dots
    * No consecutive hyphens or dots
    * Maximum length is 50 characters
    * E.g. `com.example.myapp`, `com-example-myapp`, `my-application1`
  * Default value: `default-application`

* `android`
  * `AndroidExponeaConfiguration` object containing [Android-specific configuration parameters](#android-specific-configuration-parameters).

* `ios`
  * `IOSExponeaConfiguration` object containing [iOS-specific configuration parameters](#ios-specific-configuration-parameters).

### Android-specific configuration parameters

The following parameters are specified in an `AndroidExponeaConfiguration` object. Refer to [lib/src/data/model/configuration.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/lib/src/data/model/configuration.dart) for the complete Dart definition

* `automaticPushNotifications`
  * By default, the SDK will set up a Firebase service and try to process push notifications sent from the {user.mkg} platform automatically. You can opt out by setting this to `false`.
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

* `allowWebViewCookies`
  * Flag to enable or disable cookies in WebViews.
  * Default value: `false`
  * > ❗️
    >
    > **Disclaimer**:
    > * For security purposes, cookies are by default disabled in WebViews.
    > * This setting has effect on all WebViews in the application, NOT ONLY the ones used by the SDK.
    > * DO NOT CHANGE THIS SETTING unless you know the risks associated with enabling and storing cookies.
    > * By changing this setting and enabling cookies in WebViews you take full responsibility for any security vulnerabilities or incidents caused by them.

* `appInboxDetailImageInset`
  * Defines margin-top of Image in App Inbox detail screen in dp. Default value (null) will result in `?attr/actionBarSize` defined in application theme. This is useful in case of transparent toolbar theming.


### iOS-specific configuration parameters

The following parameters are specified in an `IOSExponeaConfiguration` object. Refer to [lib/src/data/model/configuration.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/lib/src/data/model/configuration.dart) for the complete Dart definition

* `requirePushAuthorization`
  * Controls whether the SDK calls `registerForRemoteNotifications()` automatically based on the OS-reported notification authorization status.
  * When `true` (default), the SDK only calls `registerForRemoteNotifications()` once the OS reports `authorized` or `provisional` status ([Apple documentation](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus)). Use this when your app should receive an APNs token only after the user grants notification permission.
  * When `false`, the SDK calls `registerForRemoteNotifications()` unconditionally on every launch, allowing the app to receive silent pushes regardless of the user's visible notification permission state.
  * `valid` in `notification_state` events always reflects the actual OS authorization status, regardless of your `requirePushAuthorization` setting. For more details, see [Token tracking via notification_state event](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications#token-tracking-via-notification_state-event).
  * Your app is responsible for requesting notification permission from the user — the SDK never triggers the permission prompt itself.
  * Default value: `true`
  * If you also set the deprecated top-level `requirePushAuthorization`, this iOS-specific value takes precedence.

* `appGroup`
  * App group used for communication between the main app and notification extensions. This is a required field for rich push notification setup.
