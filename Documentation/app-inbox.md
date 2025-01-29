---
title: App Inbox
excerpt: Add a message inbox to your app using the Flutter SDK
slug: flutter-sdk-app-inbox
categorySlug: integrations
parentDocSlug: flutter-sdk
---

The App Inbox feature adds a mobile communication channel directly in the app. The App Inbox can receive messages sent by campaigns and store mobile push notifications for a defined period. Note that the SDK can only fetch App Inbox messages if the current app user has a customer profile identified by a [hard ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#hard-id).

Refer to the [App Inbox](https://documentation.bloomreach.com/engagement/docs/app-inbox) documentation for information on creating and sending App Inbox messages in the Engagement web app.

> 👍
>
> App Inbox is a separate module that can be enabled on request in your Engagement account by your Bloomreach CSM.

## Integrate the App Inbox

You can integrate the App Inbox through a button provided by the SDK, which opens the App Inbox messages list view.

![App Inbox button](https://raw.githubusercontent.com/exponea/exponea-flutter-sdk/main/Documentation/images/app-inbox-button.png)

You can then add the button anywhere in your app. For example:

```dart
ListTile(
  title: const Text('App Inbox'),
  subtitle: Row(
    children: const [
      SizedBox(width: 150, height: 50, child: AppInboxProvider()),
    ]
  )
),
```

The App Inbox button registers a click action to show an App Inbox list screen.

That's all that's required to integrate the App Inbox. Optionally, you can [customize](#customize-app-inbox) it to your needs.

> 📘
>
> See [home.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/example/lib/page/home.dart) for a reference implementation.

## Default App Inbox behavior

The SDK fetches and displays the App Inbox automatically as follows:

1. Display a button to access the App Inbox messages list view (integration by developer).
2. Display a messages list view. Display each item with:
   - Flag indicating whether the message is read or unread.
   - Delivery time in human-readable form (for example, `2 hours ago`).
   - Single-lined title of the message (ended by '...' for longer values).
   - Two-lined content of the message (ended by '...' for longer values).
   - Squared image if the message contains any.
   - Loading progress indicator of the list.
   - Empty Inbox title and message in case there are no messages.
   - Error title and description in case of an error loading the list
3. Call `ExponeaPlugin().trackAppInboxOpened` when the user clicks on a list item and mark the message as read automatically.
4. Display a message detail view that contains:
   - Large squared image (or a gray placeholder if the message doesn't contain an image).
   - Delivery time in human-readable form (for example, `2 hours ago`).
   - Full title of the message.
   - Full content of the message.
   - A button for each action in the message that opens a browser link or invokes a universal link. No button is displayed for an action that opens the current app.
5. Call `ExponeaPlugin().trackAppInboxClick` automatically when the user clicks a button in the message detail view.


![App Inbox messages list view and message detail view](https://raw.githubusercontent.com/exponea/exponea-flutter-sdk/main/Documentation/images/app-inbox-flutter.png)

> ❗️
>
> Note that the SDK can only fetch App Inbox messages if the current app user has a customer profile identified by a [hard ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#hard-id).

> ❗️
>
> The behavior of `trackAppInboxOpened` and `trackAppInboxClick` may be affected by the tracking consent feature, which in enabled mode considers the requirement of explicit consent for tracking. Refer to [Consent](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking-consent) for details.

## Customize App Inbox

Although the App Inbox works out of the box once the button has been integrated in your app, you may want to customize it to your app's requirements.

### Localization

The SDK provides the following UI labels in English. You can modify these or add localized labels by defining customized strings.

For Android, add to your `strings.xml` files:

```xml
<string name="exponea_inbox_button">Inbox</string>
<string name="exponea_inbox_title">Inbox</string>
<string name="exponea_inbox_defaultTitle">Inbox message</string>
<string name="exponea_inbox_emptyTitle">Empty Inbox</string>
<string name="exponea_inbox_emptyMessage">You have no messages yet.</string>
<string name="exponea_inbox_errorTitle">Something went wrong :(</string>
<string name="exponea_inbox_errorMessage">We could not retrieve your messages.</string>
<string name="exponea_inbox_mainActionTitle">See more</string>
```

For iOS, add to your `Localizable.string` files:

```text
"exponea.inbox.button" = "Inbox";
"exponea.inbox.title" = "AppInbox";
"exponea.inbox.loading" = "Loading messages...";
"exponea.inbox.emptyTitle" = "Empty Inbox";
"exponea.inbox.emptyMessage" = "You have no messages yet.";
"exponea.inbox.errorTitle" = "Something went wrong :(";
"exponea.inbox.errorMessage" = "We could not retrieve your messages.";
"exponea.inbox.defaultTitle" = "Message";
"exponea.inbox.mainActionTitle" = "See more";
```

### Customize UI styles

The App Inbox screens are designed to satisfy most customers' needs. However, they may not fit the design of your application. You can customize colors and text styles through configuration.

```dart
_plugin.setAppInboxProvider(AppInboxStyle(
      appInboxButton: SimpleButtonStyle(
        // ButtonStyle
        textOverride: 'text value',
        textColor: 'color',
        backgroundColor: 'color',
        showIcon: true,
        textSize: '12px',
        enabled: true,
        borderRadius: '5px',
        textWeight: 'bold|normal|100..900'
      ),
      detailView: DetailViewStyle(
        title: TextViewStyle(
          // TextViewStyle
          visible: true,
          textColor: 'color',
          textSize: '12px',
          textWeight: 'bold|normal|100..900',
          textOverride: 'text'
        ),
        content: TextViewStyle(...),
        receivedTime: TextViewStyle(...),
        image: ImageViewStyle(
          // ImageViewStyle
          visible: true,
          backgroundColor: 'color'
        ),
        button: SimpleButtonStyle(),
      },
      listView: ListScreenStyle(
        emptyTitle: TextViewStyle(...),
        emptyMessage: TextViewStyle(...),
        errorTitle: TextViewStyle(...),
        errorMessage: TextViewStyle(...),
        progress: ProgressBarStyle(
          // ProgressBarStyle
          visible: true,
          progressColor: 'color',
          backgroundColor: 'color'
        ),
        list: AppInboxListViewStyle(
          backgroundColor: 'color',
          item: AppInboxListItemStyle(
            backgroundColor: 'color',
            readFlag: ImageViewStyle(),
            receivedTime: TextViewStyle(...),
            title: TextViewStyle(...),
            content: TextViewStyle(...),
            image: ImageViewStyle(),
          ),
        ),
      )
    })
```

Supported colors formats:

* Short hex `#rgb` or with alpha `#rgba`
* Hex format `#rrggbb` or `#rrggbbaa`
* RGB format `rgb(255, 255, 255)`
* RGBA format `rgba(255, 255, 255, 1.0)` or `rgba(255 255 255 / 1.0)`
* ARGB format `argb(1.0, 255, 255, 255)`
* Name format `yellow` (names has to be supported by Android/iOS platform)

Supported size formats:

* Pixels `12px` or `12`
* Scaleable Pixels `12sp`
* Density-independent Pixels `12dp` or `12dip`
* Points `12pt`
* Inches `12in`
* Millimeters `12mm`

> ❗️
>
> The iOS platform does not support DPI conversions and only accepts number values for size.

Supported text weight formats:

* 'normal' - normal/regular style on both platforms
* 'bold' - bold style on both platforms
* Number from `100` to `900` - mainly usable on iOS. Limited support on Android (100-600 means 'normal'; 700-900 means 'bold')

> 👍
>
> You may register your own styling at any time - before [SDK initialization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#initialize-the-sdk) or later in some of your screens. Every action in scope of the App Inbox uses currently registered styles. We recommend to register your styles configuration right before you initialize the SDK.

#### Android style rules

The style rules defined for the App Inbox UI components are listed below. You can override them in your `styles.xml` files.

```xml
<style name="Theme.AppInboxListActivity" parent="@style/Theme.AppCompat.NoActionBar">
    <!-- Screen shows App Inbox list -->
    <!-- This style is applied to 'android:theme' activity parameter -->
</style>
<style name="Theme.AppInboxDetailActivity" parent="@style/Theme.AppCompat.NoActionBar">
    <!-- Screen shows App Inbox message detail -->
    <!-- This style is applied to 'android:theme' activity parameter -->
</style>
<style name="AppInboxItemReceivedTime">
    <!-- TextView shows delivery time in App Inbox list -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxItemTitle">
    <!-- TextView shows title in App Inbox list -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxItemContent">
    <!-- TextView shows message content in App Inbox list -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxDetailReceivedTime">
    <!-- TextView shows delivery time in message detail -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxDetailTitle">
    <!-- TextView shows title in message detail -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxDetailContent">
    <!-- TextView shows message content in message detail -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="Theme.AppInboxAppBarOverlay" parent="ThemeOverlay.AppCompat.Dark.ActionBar">
    <!-- AppBarLayout is shown in both list and detail screens -->
    <!-- This style is applied to 'android:theme' parameter -->
</style>
<style name="Theme.AppInboxAppBarPopupOverlay" parent="ThemeOverlay.AppCompat.Light">
    <!-- Toolbar is shown inside AppBarLayout -->
    <!-- This style is applied to 'app:popupTheme' parameter -->
</style>
<style name="AppInboxButton" parent="@style/Widget.AppCompat.Button">
    <!-- Button opens App Inbox list screen -->
    <!-- This style is applied to 'style' button parameter -->
</style>
<style name="AppInboxActionButton" parent="@style/Widget.AppCompat.Button">
    <!-- Button invokes App Inbox message action in detail -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxEmptyStatusTitle">
    <!-- TextView shows title for App Inbox list empty state -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxEmptyStatusMessage">
    <!-- TextView shows message for App Inbox list empty state -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxErrorStatusTitle">
    <!-- TextView shows title for App Inbox list error state -->
    <!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxErrorStatusMessage">
<!-- TextView shows message for App Inbox list error state -->
<!-- This style is applied to 'style' parameter -->
</style>
<style name="AppInboxStatusLoading" parent="android:Widget.DeviceDefault.ProgressBar.Large">
    <!-- ProgressBar shown for App Inbox list loading state -->
    <!-- This style is applied to 'style' parameter -->
</style>
```

### Customize UI Components

If use of the App Inbox button flow doesn't suit your needs, you can integrate the App Inbox List View through a widget provided by the SDK, which displays the App Inbox messages list. Also, you can use Detail view, once the user picks a message from the list to show.

#### App Inbox List View

The `AppInboxListView` implements all the data handling (fetching, displaying data, action listeners, etc.).

The methods `ExponeaPlugin().trackAppInboxOpened` and `ExponeaPlugin().markAppInboxAsRead` are called automatically when the user clicks on an item.

The click action for each item in the list triggers the `onAppInboxItemClicked` callback with `AppInboxMessage` as a parameter. You can then navigate the user to the page showing detail of that clicked message. For example:

```dart
AppInboxListView(
  onAppInboxItemClicked: (AppInboxMessage message) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppInboxDetailPage(messageId: message.id)));
  },
)
```

#### App Inbox Detail View

The `AppInboxDetailView` implements all the data handling (fetching, displaying data, action listeners, etc.).

The method `ExponeaPlugin().trackAppInboxClick` is called automatically when the user clicks on an action.

You can show detail of a message as a full-screen View. For example:

```dart
Scaffold(
  appBar: AppBar(title: const Text('App inbox message')),
  body: AppInboxDetailView(messageId: messageId),
);
```

### App Inbox data API

The SDK provides methods to access App Inbox data directly without accessing the UI layer.

#### Fetch App Inbox

The App Inbox is assigned to an existing customer account (identified by a hard ID). Calling either of the following methods will clear the App Inbox:

- `ExponeaPlugin().identifyCustomer`
- `ExponeaPlugin().anonymize`

To prevent large data transfers on each fetch, the SDK stores the App Inbox locally and loads incrementally. The first fetch will transfer the entire App Inbox, but subsequent fetches will only transfer new messages.

The App Inbox assigned to the current customer can be fetched as follows:

```dart
var messages = await ExponeaPlugin().fetchAppInbox();
```

It's also possible to fetch a single message by its ID from the App Inbox as follows:

```dart
var message = await ExponeaPlugin().fetchAppInboxItem(messageId);
```

Fetching a single message triggers fetching the entire App Inbox (including incremental loading) but will retrieve the data from local storage if the App Inbox was fetched previously.

#### Mark message as read

Use the `markAppInboxAsRead` method, passing an App Inbox message object as argument, to mark the message as read:

```dart
var markedAsRead = ExponeaPlugin().markAppInboxAsRead(message);
```

> ❗️
>
> Marking a message as read using the `markAppInboxAsRead` method does not trigger a tracking event for opening the message. To track an opened message, you need to call the `ExponeaPlugin().trackAppInboxOpened` method). 

### Track App Inbox events manually

The SDK tracks App Inbox events automatically by default. In case of a [custom implementation](#customize-app-inbox), it is the developers' responsibility to use the relevant tracking methods in the right places.

#### Track opened App Inbox message

Use the `ExponeaPlugin().trackAppInboxOpened(MessageItem)` method to track the opening of App Inbox messages.

The behavior of `trackAppInboxOpened` may be affected by the tracking consent feature, which, when enabled, requires explicit consent for tracking. Refer to [Tracking consent](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking-consent) for details.

If you want to ignore tracking consent, use `ExponeaPlugin().trackAppInboxOpenedWithoutTrackingConsent` instead. This method will track the event regardless of consent.

#### Track clicked App Inbox message action

Use the `ExponeaPlugin().trackAppInboxClick(MessageItemAction, MessageItem)` method to track action invocations in App Inbox messages.

The behavior of `trackAppInboxClick` may be affected by the tracking consent feature, which, when enabled, requires explicit consent for tracking. Refer to [Tracking consent](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking-consent) for details.

If you want to ignore tracking consent, use `ExponeaPlugin().trackAppInboxClickWithoutTrackingConsent` instead. This method will track the event regardless of consent.
