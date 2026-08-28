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

## Integration modes

The SDK supports two integration modes, selected via `integrationConfig`:

* **Project** (`ProjectIntegrationConfig`): classic Bloomreach Engagement project integration using `projectToken` and `authorizationToken`. This is the default mode for existing apps.
* **Stream** (`StreamIntegrationConfig`): [Data hub event stream](https://documentation.bloomreach.com/data-hub/docs/event-streams) integration using `streamId`. API authentication uses a runtime **JWT auth token** via `setSdkAuthToken()` instead of `authorizationToken` or `advancedAuthEnabled`. See [SDK auth token authorization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization#sdk-auth-token-authorization).

Prefer the new `integrationConfig` field. Legacy flat fields (`projectToken`, `authorizationToken`, `baseUrl`, `projectMapping`) remain supported for backward compatibility but are **deprecated**. The SDK wraps them into `ProjectIntegrationConfig` at configure time and logs a deprecation warning.

### Project configuration

```dart
final config = ExponeaConfiguration(
  integrationConfig: ProjectIntegrationConfig(
    projectToken: 'my-project-token',
    authorizationToken: 'Token my-auth-token',
    baseUrl: 'https://api.exponea.com',
  ),
);
```

Legacy style (still works):

```dart
final config = ExponeaConfiguration(
  projectToken: 'my-project-token',
  authorizationToken: 'Token my-auth-token',
  baseUrl: 'https://api.exponea.com',
);
```

### Stream configuration

```dart
final config = ExponeaConfiguration.stream(
  streamId: 'my-stream-id',
  baseUrl: 'https://stream.exponea.com',
);

// equivalent:
final config = ExponeaConfiguration(
  integrationConfig: StreamIntegrationConfig(
    streamId: 'my-stream-id',
    baseUrl: 'https://stream.exponea.com',
  ),
);
```

When using Stream configuration:

* **Don't** set `authorizationToken` on the configuration—authentication is JWT-based at runtime.
* `advancedAuthEnabled` and `integrationRouteMap` are **Project-only**. If set alongside a Stream integration, the SDK logs a warning and ignores them.

### Multi-project routing

Use `integrationRouteMap` to route specific event types to additional **Project** integrations. Stream destinations aren't valid entries in the route map.

```dart
final config = ExponeaConfiguration(
  integrationConfig: ProjectIntegrationConfig(
    projectToken: 'default-token',
    authorizationToken: 'Token default-auth',
  ),
  integrationRouteMap: {
    EventType.trackEvent: [
      ProjectIntegrationConfig(
        projectToken: 'analytics-token',
        authorizationToken: 'Token analytics-auth',
      ),
    ],
  },
);
```

`projectMapping` with `ExponeaProject` entries is deprecated; use `integrationRouteMap` with `ProjectIntegrationConfig` instead.

### Runtime validation

At configure time, the SDK validates integration settings:

* Either `integrationConfig` **or** legacy `projectToken` + `authorizationToken` must be set—one is required, and they're mutually exclusive
* Stream config must not be combined with `advancedAuthEnabled` or `integrationRouteMap` (warning + ignore).

## Configuration parameters

The following parameters are specified in an `ExponeaConfiguration` object. Refer to [lib/src/data/model/configuration.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/lib/src/data/model/configuration.dart) for the complete Dart definition.

* `integrationConfig`
  * **Required in new integrations.** Project or Stream integration settings for the default destination.
  * Use `ProjectIntegrationConfig` for a standard Engagement project, or `StreamIntegrationConfig` for a [Data hub event stream](https://documentation.bloomreach.com/data-hub/docs/event-streams) integration.
  * `ProjectIntegrationConfig` fields:
    * `projectToken` **(required)** — your Engagement project token, found in the Engagement web app under **Project settings** > **Access management** > **API**
    * `authorizationToken` **(required)** — your Engagement public API key; must be a **public** key (see [Mobile SDKs API Access Management](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management))
    * `baseUrl` — API base URL; defaults to `https://api.exponea.com`
  * `StreamIntegrationConfig` fields:
    * `streamId` **(required)** — your Data Hub stream ID, found in the Data Hub app under **Event streams** > *your stream* > **Access Security**
    * `baseUrl` — optional base URL override for the stream endpoint; defaults to `https://api.exponea.com`
  * The two modes are mutually exclusive; you cannot provide both `projectToken` and `streamId` in the same `integrationConfig`.
  * Example with `ProjectIntegrationConfig`:
    ```dart
    integrationConfig: ProjectIntegrationConfig(
      projectToken: 'YOUR_PROJECT_TOKEN',
      authorizationToken: 'Token YOUR_API_KEY',
      baseUrl: 'https://api.exponea.com',
    ),
    ```
  * Example with `StreamIntegrationConfig`:
    ```dart
    integrationConfig: StreamIntegrationConfig(
      streamId: 'YOUR_STREAM_ID',
      baseUrl: 'https://api.exponea.com',
    ),
    ```
  * See also [Integration modes](#integration-modes).

* `integrationRouteMap`
  * If you need to track events to additional Engagement projects, define a mapping between event types and `ProjectIntegrationConfig` objects.
  * An event is always tracked to the default integration and any integrations in this map.
  * **Only applicable when `integrationConfig` is a `ProjectIntegrationConfig`.** Ignored for `StreamIntegrationConfig`.
  * Example:
    ```dart
    integrationRouteMap: {
      EventType.banner: [
        ProjectIntegrationConfig(
          projectToken: 'other-project-token',
          authorizationToken: 'Token other-auth-token',
        ),
      ],
    }
    ```

* `projectToken` **(deprecated)**
   * Your project token. You can find this in the {user.mkg} web app under `Project settings` > `Access management` > `API`.
   * **Required** when using legacy flat configuration (without `integrationConfig`). Use `integrationConfig: ProjectIntegrationConfig(...)` instead.

* `authorizationToken` **(deprecated)**
   * Your {user.mkg} API key.
   * The token must be an {user.mkg} **public** key. See [Mobile SDKs API Access Management](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management) for details.
   * For more information, refer to [Exponea API documentation](https://docs.exponea.com/reference#access-keys).
   * **Required** when using legacy flat configuration (without `integrationConfig`). Not used in Stream mode.

* `baseUrl` **(deprecated)**
  * Your API base URL which can be found in the {user.mkg} web app under `Project settings` > `Access management` > `API`.
  * Default value `https://api.exponea.com`.
  * If you have custom base URL, you must set this property.
  * Use `integrationConfig` with `ProjectIntegrationConfig` or `StreamIntegrationConfig` instead.

* `projectMapping` **(deprecated)**
  * If you need to track some events to a different {user.mkg} project, you can define a mapping between event types and {user.mkg} projects.
  * An event is always tracked to the default project and any projects it is mapped to.
  * Use `integrationRouteMap` with `ProjectIntegrationConfig` entries instead.
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
  * If set, the SDK uses advanced authorization for communication with the {user.mkg} APIs listed in [Customer token authorization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization#customer-token-authorization).
  * Refer to the [authorization documentation](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization) for details.
  * **Only applicable when `integrationConfig` is a `ProjectIntegrationConfig`.** If set to `true` with a `StreamIntegrationConfig` integration, the SDK logs a warning and ignores the setting. For stream-based integrations, refer to [SDK auth token authorization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization#sdk-auth-token-authorization).

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
