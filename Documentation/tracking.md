---
title: Tracking for Flutter SDK
excerpt: Track customers and events using the Flutter SDK
slug: flutter-sdk-tracking
categorySlug: integrations
parentDocSlug: flutter-sdk
---

You can track events in Engagement to learn more about your app’s usage patterns and to segment your customers by their interactions.

By default, the SDK tracks certain events automatically, including:

* Installation (after app installation and after invoking [anonymize](#anonymize))
* User session start and end
* Banner event for showing an in-app message or content block
* `notification_state` event for push notification token tracking (SDK versions 2.3.0 and higher). [Learn more](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications#token-tracking-via-notification_state-event).


Additionally, you can track any custom event relevant to your business.

> 📘
>
> Also see [Mobile SDK tracking FAQ](https://support.bloomreach.com/hc/en-us/articles/18153058904733-Mobile-SDK-tracking-FAQ) at Bloomreach Support Help Center.

> ❗️ Protect the privacy of your customers
>
> Make sure you have obtained and stored tracking consent from your customer before initializing Exponea Flutter SDK.
>
> To ensure you're not tracking events without the customer's consent, you can use `ExponeaPlugin().clearLocalCustomerData(appGroup)` when a customer opts out from tracking (this applies to new users or returning customers who have previously opted out). This will bring the SDK to a state as if it was never initialized. This option also prevents reusing existing cookies for returning customers.
>
> Refer to [Clear local customer data](#clear-local-customer-data) for details.
>
> If customer denied tracking consent after Exponea Flutter SDK is initialized, you can use `ExponeaPlugin().stopIntegration()` to stop SDK integration and remove all locally stored data.
>
> Refer to [Stop SDK integration](#stop-sdk-integration) for details.

> 👍
>
> All examples on this page assume the `ExponeaPlugin` is available as `_plugin`. Refer to [Initialize the SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#initialize-the-sdk) for details.

## Events

### Track event

Use the `trackEvent()` method with an `Event` object as an argument to track any custom event type relevant to your business.

You can use any name for a custom event type. We recommended using a descriptive and human-readable name.

Refer to the [Custom Events](https://documentation.bloomreach.com/engagement/docs/custom-events) documentation for an overview of commonly used custom events.

#### Arguments

| Name  | Type            | Description |
| ----- | ----------------| ----------- |
| event | [Event](#event) | Event object. |

##### Event

| Name                | Type                 | Description |
| --------------------| -------------------- | ----------- |
| name **(required)** | String               | Name of the event type, for example `screen_view`. |
| properties          | Map<String, dynamic> | Dictionary of event properties. |
| timestamp           | DateTime?            | Unix timestamp (in seconds) specifying when the event was tracked. The default value is the current time. |

#### Examples

Imagine you want to track which screens a customer views. You can create a custom event `screen_view` for this.

First, create an `Event` with the name and properties you want to track with this event. In our example, you want to track the name of the screen, so you include a property `screen_name` along with any other relevant properties:

```dart
final event = Event(
  name: 'screen_view',
  properties: {
    'screen_name': "dashboard",
    'other_property': 123.45,
  },
);
```

Pass the event object to `trackEvent()` as follows:

```dart
_plugin.trackEvent(event);
```

The second example below shows how you can use a nested structure for complex properties if needed:

```dart
final event = Event(
  name: 'purchase',
  properties: {
    'purchase_status': "success",
    'product_list': [
        {'product_id': 'abc123', 'quantity': 2},
        {'product_id': 'abc456', 'quantity': 1}
    ],
    'total_price': 7.99,
  },
);
_plugin.trackEvent(event);
```

> 👍
>
> Optionally, you can provide a custom `timestamp` if the event happened at a different time. By default the current time will be used.

## Customers

[Identifying your customers](https://documentation.bloomreach.com/engagement/docs/customer-identification) allows you to track them across devices and platforms, improving the quality of your customer data.

Without identification, events are tracked for an anonymous customer, only identified by a cookie. Once the customer is identified by a hard ID, these events will be transferred to a newly identified customer.

> 👍
>
> Keep in mind that, while an app user and a customer record can be related by a soft or hard ID, they are separate entities, each with their own lifecycle. Take a moment to consider how their lifecycles relate and when to use [identify](#identify) and [anonymize](#anonymize).

### Identify

Use the `identifyCustomer()` method with a `Customer` object as an argument to identify a customer using their unique [hard ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#hard-id).

The default hard ID is `registered` and its value is typically the customer's email address. However, your Engagement project may define a different hard ID.

Optionally, you can track additional customer properties such as first and last names, age, etc.

#### Customer identification and local data

The SDK stores customer data, including the hard ID, in a local cache on the device. If you need to remove the hard ID from local storage, call [anonymize](#anonymize) in your app.

Although you can use `identifyCustomer` with a [soft ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#section-soft-id), use caution—especially after anonymization. In some cases, this can unintentionally associate the current user with the wrong customer profile.

> ❗️Warning
>
> If a customer profile is anonymized or deleted in the Bloomreach Engagement web app, initializing the SDK again in the app can cause the profile to be reidentified or recreated from locally cached data. Always clear local data appropriately to prevent unintended profile recreation.


#### Arguments

| Name                     | Type                  | Description |
| ------------------------ | --------------------- | ----------- |
| customer **(required)**  | [Customer](#customer) | Customer object. |

##### Customer

| Name               | Type                 | Description |
| -------------------| -------------------- | ----------- |
| ids **(required)** | Map<String, String>  | Dictionary of customer unique identifiers. Only identifiers defined in the Engagement project are accepted. |
| properties         | Map<String, dynamic> | Dictionary of customer properties. |

#### Examples

First, create a `Customer` object containing at least the customer's hard ID and, optionally, a dictionary with additional customer properties:

```dart
final customer = Customer(
  ids: {
    'registered': 'jane.doe@example.com',
  },
  properties: {
    'first_name': 'Jane',
    'last_name': 'Doe',
    'age', 32
  },
);
```

Pass the customer object to `identifyCustomer()`:

```dart
_plugin.identifyCustomer(customer);
```

If you only want to update the customer ID without any additional properties, you can pass an empty dictionary into `properties`:

```dart
final customer = Customer(
  ids: {
    'registered': 'jane.doe@example.com',
  },
  properties: {},
);
_plugin.identifyCustomer(customer);
```

### Anonymize

Use the `anonymize()` method to delete all information stored locally and reset the current SDK state. A typical use case for this is when the user signs out of the app.

Invoking this method will cause the SDK to:

* Remove the push notification token for the current customer from local device storage and the customer profile in Engagement.
* Clear local repositories and caches, excluding tracked events.
* Track a new session start if `automaticSessionTracking` is enabled.
* Create a new customer record in Engagement (a new `cookie` soft ID is generated).
* Assign the previous push notification token to the new customer record.
* Preload in-app messages, in-app content blocks, and app inbox for the new customer.
* Track a new `installation` event for the new customer.

#### How tokens are removed during anonymization

The SDK removes push notification tokens differently depending on the version:

**SDK versions below 2.3.0:**

- Assigns an empty string to the `google_push_notification_id`, `huawei_push_notification_id`, or `apple_push_notification_id` customer property.

**SDK versions 2.3.0 and higher:**

- Tracks a `notification_state` event with `valid = false` and `description = Invalidated`

> 📘 Note
>
> Learn more about [Token tracking via notification_state event](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications#token-tracking-via-notification_state-event).

You can also use the `anonymize` method to switch to a different Engagement project. The SDK will then track events to a new customer record in the new project, similar to the first app session after installation on a new device.

#### Examples

```dart
_plugin.anonymize();```

Switch to a different project:

```dart
final configChange = ExponeaConfigurationChange(
  project: ExponeaProject(
    projectToken: 'new-project-token',
    authorizationToken: 'new-authorization-token',
  ),
  mapping: {
    EventType.payment: [
      ExponeaProject(
        projectToken: 'special-project-for-payments',
        authorizationToken: 'payment-authorization-token',
        baseUrl: 'https://api-payments.some-domain.com',
      ),
    ],
  },
);
_plugin.anonymize(configChange);
```

## Sessions

The SDK tracks sessions automatically by default, producing two events: `session_start` and `session_end`.

The session represents the actual time spent in the app. It starts when the application is launched and ends when it goes into the background. If the user returns to the app before the session times out, the application will continue the current session.

The default session timeout is 60 seconds. Set `sessionTimeout` in the [SDK configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration) to specify a different timeout.

### Track session manually

To disable automatic session tracking, set `automaticSessionTracking` to `false` in the [SDK configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration).

Use the `trackSessionStart()` and `trackSessionEnd()` methods to track sessions manually.

#### Examples

```dart
_plugin_.trackSessionStart()
```

```dart
_plugin_.trackSessionEnd()
```

### Override default session event properties

The SDK automatically tracks a number of default properties for the `session_start` and `session_end` events, including `ip`, `city`, `country`, etc.

You can override the value of any of these properties by including them in the `defaultProperties` configuration parameter (see below). For example, if you don't want to track customers' IP addresses, you can set the `ip` property's default value to an empty string.

## Push notifications

If developers [integrate push notification functionality](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications#integration) in their app, the SDK automatically tracks the push notification token by default.

On Android, you can disable automatic push notification tracking by setting the Boolean value of the `automaticPushNotification` property to `false` in the SDK's [Android-specific configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration#android-specific-configuration-parameters). It is then up to the developer to [manually track push notifications](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications#manually-track-push-notifications).

> ❗️
>
> The Flutter SDK currently doesn't support disabling automatic push notification tracking on iOS.

> ❗️
>
> The behavior of push notification tracking may be affected by the tracking consent feature, which in enabled mode requires explicit consent for tracking. Refer to the [consent documentation](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking-consent) for details.

### Track token manually

Use either the `trackPushToken()` (Firebase) or `trackHmsPushToken` (Huawei) method to manually track the token for receiving push notifications. The token is assigned to the currently logged-in customer (with the `identifyCustomer` method).

Invoking this method will track a push token immediately regardless of the value of `pushTokenTrackingFrequency` (refer to the [Configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration) documentation for details).

Each time the app becomes active, the SDK calls `verifyPushStatusAndTrackPushToken` and tracks the token.

> 📘 Note
>
> SDK versions 2.3.0 and higher use event-based token tracking. Learn more about [Token tracking via notification_state event](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications#token-tracking-via-notification_state-event).

#### Arguments

| Name                 | Type    | Description |
| ---------------------| ------- | ----------- |
| token **(required)** | String  | String containing the push notification token. |

#### Example 

Firebase:

```dart
ExponeaPlugin().trackPushToken("value-of-push-token")
```

Huawei:

```dart
ExponeaPlugin().trackHmsPushToken("value-of-push-token")
```

> ❗️
>
> Remember to invoke [anonymize](#anonymize) whenever the user signs out to ensure the push notification token is removed from the user's customer profile. Failing to do this may cause multiple customer profiles share the same token, resulting in duplicate push notifications.

### Track push notification delivery manually

Use the `trackDeliveredPush` method to [manually track push notification delivery](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications#track-delivered-push-notification).

#### Arguments

The `trackDeliveredPush` method accepts a notification payload in JSON format as argument.

For an example payload, refer to [Push notifications](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications#payload-example).

#### Example

```dart
ExponeaPlugin().trackDeliveredPush(payload)
```

### Track push notification click manually

Use the `trackClickedPush` method to [manually track push notification clicks](https://documentation.bloomreach.com/engagement/docs/android-sdk-push-notifications#track-clicked-push-notification).

#### Arguments

The `trackClickedPush` method accepts a notification payload in JSON format as argument.

For an example payload, refer to [Push notifications](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications#payload-example).

#### Example

```dart
ExponeaPlugin().trackClickedPush(payload)
```

## Payments

The SDK provides a convenience method `trackPaymentEvent` to help you track information about a payment for a product or service within the application.


### Track payment event

Use the `trackPaymentEvent()` method to track payments.

#### Arguments

| Name                         | Type          | Description |
| -----------------------------| ------------- | ----------- |
| purchasedItem **(required)** | PurchasedItem | Dictionary of payment properties. |
| timestamp                    | DateTime?     | Unix timestamp (in seconds) specifying when the event was tracked. The default value is the current time. |


#### Examples

First, create a `PurchasedItem` containing the basic information about the purchase:

```dart
final item = PurchasedItem(
    value = 12.34,
    currency = "EUR",
    paymentSystem = "Virtual",
    productId = "handbag",
    productTitle = "Awesome leather handbag"
)
```

Pass the `PurchasedItem` to `trackPaymentEvent` as follows:

```dart
ExponeaPlugin().trackPaymentEvent(item)
```

## Clear local customer data

Your application should always ask customers for consent to track their app usage. If the customer consents to tracking events at the application level but not at the personal data level, using the `anonymize()` method is usually sufficient.

If the customer doesn't consent to any tracking, it's recommended not to initialize the SDK at all.

If the customer requests deletion of personalized data before the SDK is initialized, use the `clearLocalCustomerData(appGroup)` method to remove all locally stored information. For details on the appGroup parameter, see [Using the appGroup parameter on iOS](#using-the-appgroup-parameter-on-ios)

The customer may also revoke all tracking consent after the SDK is fully initialized and tracking is enabled. In this case, you can stop SDK integration and remove all locally stored data using the [stopIntegration](#stop-sdk-integration) method.

Invoking this method will cause the SDK to:

* Remove the push notification token for the current customer from local device storage.
* Clear local repositories and caches, including all previously tracked events that haven't been flushed yet.
* Clear all session start and end information.
* Remove the customer record stored locally.
* Clear any previously loaded in-app messages, in-app content blocks, and app inbox messages.
* Clear the SDK configuration from the last invoked initialization.
* Stop handling of received push notifications.
* Stop tracking of deep links and universal links (your app's handling of them isn't affected).

### Using the appGroup parameter on iOS
The `clearLocalCustomerData()` method includes an optional appGroup parameter:
* On iOS, set this parameter to match the application group identifier configured for your app.
* If your app uses multiple application groups, call the method separately for each group.
* If your app doesn't use an application group, you can omit this parameter.
* This parameter has no effect on Android.

## Stop SDK integration

Your application should always ask the customer for consent to track their app usage. If the customer consents to tracking of events at the application level but not at the personal data level, using the `anonymize()` method is normally sufficient.

If the customer doesn't consent to any tracking before the SDK is initialized, it's recommended that the SDK isn't initialized at all. For the case of deleting personalized data before SDK initialization, see more info in the usage of the [clearLocalCustomerData](#clear-local-customer-data) method.

The customer may also revoke all tracking consent later, after the SDK is fully initialized and tracking is enabled. In this case, you can stop SDK integration and remove all locally stored data by using the `ExponeaPlugin().stopIntegration()` method.

Use the `stopIntegration()` method to delete all information stored locally and stop the SDK if it is already running.

Invoking this method will cause the SDK to:

* Remove the push notification token for the current customer from local device storage.
* Clear local repositories and caches, including all previously tracked events that were not flushed yet.
* Clear all session start and end information.
* Remove the customer record stored locally.
* Clear any In-app messages, In-app content blocks, and App inbox messages previously loaded.
* Clear the SDK configuration from the last invoked initialization.
* Stop handling of received push notifications.
* Stop tracking of Deep links and Universal links (your app's handling of them is not affected).

If the SDK is already running, invoking of this method also:

* Stops and disables session start and session end tracking even if your application tries later on.
* Stops and disables any tracking of events even if your application tries later on.
* Stops and disables any flushing of tracked events even if your application tries later on.
* Stops displaying of In-app messages, In-app content blocks, and App inbox messages.
    * Already displayed messages are dismissed.
    * Please validate dismiss behaviour if you [customized](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-app-inbox#customize-app-inbox) the App Inbox UI layout.

After invoking the `stopIntegration()` method, the SDK will drop any API method invocation until you [initialize the SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#initialize_the_sdk) again.

### Use cases

Correct usage of `stopIntegration()` method depends on the use case so consider all scenarios.

#### Request customer consent

Always respect user privacy—not only to comply with regulations like GDPR, but also to build trust and deliver ethical digital experiences.

When requesting permission in your mobile app, make sure your requests are clear, transparent, and relevant to the context. Clearly explain why you need the permission and ask for it only when necessary, so users can make an informed decision.

You may use system dialog or in-app messages for that purpose.

![](https://raw.githubusercontent.com/exponea/exponea-flutter-sdk/main/Documentation/images/gdpr-dialog-example.png)

In the case of the in-app message dialog, you can customize [In-app message action callback](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-in-app-messages#customize-in-app-message-actions) to handle the user's decision about allowing or denying tracking permission.

```dart
// If overrideDefaultBehavior is set to true, default in-app action will not be performed ( e.g. deep link )
const overrideDefaultBehavior = false;
// If trackActions is set to false, click and close in-app events will not be tracked automatically
const trackActions = false;
final subscription = _plugin.inAppMessageActionStream(overrideDefaultBehavior: overrideDefaultBehavior, trackActions: trackActions).listen((inAppMessageAction) {
  if (<your-special-condition>) {
    switch(inAppMessageAction.type) {
      case InAppMessageActionType.click:
        _plugin.trackInAppMessageClick(inAppMessageAction.message!, inAppMessageAction.button!);
        break;
      case InAppMessageActionType.close:
        _plugin.trackInAppMessageClose(inAppMessageAction.message!, interaction: inAppMessageAction.interaction ?? true);
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

#### Stop the SDK but upload tracked data

The SDK caches data (such as sessions, events, and customer properties) in an internal local database and periodically sends them to Bloomreach Engagement. These data are kept locally if the device has no network, or if you configured SDK to upload them less frequently.

Invoking the `stopIntegration()` method will remove all these locally stored data that may not be uploaded yet. To avoid loss of these data, invoke request to flush them before stopping the SDK:

```dart
// Flushing requires that SDK is initialized
final _plugin = ExponeaPlugin();
_plugin.configure(...);
// Invoke flush force-fully
_plugin.setFlushMode(FlushMode.manual);
await _plugin.flushData();
// All data are uploaded, we may stop SDK
_plugin.stopIntegration();
```

#### Stop the SDK and wipe all tracked data

The SDK caches data (such as sessions, events, and customer properties) in an internal local database and periodically sends them to the Bloomreach Engagement app. These data are kept locally if the device has no network, or if you configured SDK to upload them less frequently.

If a customer is removed from the Bloomreach Engagement platform, you may also need to remove their data from local storage.

**Don't initialize the SDK after deleting the customer.** Depending on your configuration, initializing the SDK could trigger an upload of any locally stored events, which may unintentionally recreate the customer profile in Bloomreach Engagement using the stored customer IDs.

To prevent this, invoke `stopIntegration()` immediately without initializing the SDK:

```dart
ExponeaPlugin().stopIntegration();
```

This results in all previously stored data being removed from the device. The next SDK initialization will be considered a fresh new start.

#### Stop the already running SDK

The method `stopIntegration()` can be invoked anytime on a configured and running SDK.

This is useful if a customer initially consented to tracking but later revokes their consent. When consent is withdrawn, invoke `stopIntegration()` immediately to stop all tracking activities.

```dart
// User gave you permission to track
final _plugin = ExponeaPlugin();
_plugin.configure(...);

// Later, user decides to stop tracking
_plugin.stopIntegration()
```

This results in the SDK stopping all internal processes (such as session tracking and push notifications handling) and removing all locally stored data.

> ❗️
>
> After calling `stopIntegration()`, the SDK will not track or upload any further data. If you need to upload any tracked data to Bloomreach Engagement before stopping the SDK, [flush the data synchronously](#stop-the-sdk-but-upload-tracked-data) before invoking `stopIntegration()`.

#### Customer denies tracking consent

Ask for the customer’s tracking consent as early as possible in your application. If the customer denies consent, don't initialize the SDK. This prevents any tracking or data storage from occurring.


## Default properties

You can [configure](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration) default properties to be tracked with every event. Note that the value of a default property will be overwritten if the tracking event has a property with the same key.

```dart
final config = ExponeaConfiguration(
    projectToken: 'YOUR_PROJECT_TOKEN',
    authorizationToken: 'YOUR_API_KEY',
    baseUrl: 'YOUR_API_BASE_URL', 
    defaultProperties: const {
    'thisIsADefaultStringProperty': 'This is a default string value',
    'thisIsADefaultIntProperty': 1
    },
_plugin.configure(configuration)
```

After initializing the SDK, you can change the default properties using the method `ExponeaPlugin.setDefaultProperties()`.
