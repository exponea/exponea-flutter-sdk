---
title: In-App Content Blocks
excerpt: Display native in-app content blocks based on definitions set up in Engagement using the Flutter SDK
slug: flutter-sdk-in-app-content-blocks
categorySlug: integrations
parentDocSlug: flutter-sdk-in-app-personalization
---

In-app content blocks provide a way to display campaigns within your mobile applications that seamlessly blend with the overall app design. Unlike [in-app messages](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-in-app-messages) that appear as overlays or pop-ups demanding immediate attention, in-app content blocks display inline with the app's existing content.

You can strategically position placeholders for in-app content blocks within your app. You can customize the behavior and presentation to meet your specific requirements.

> 📘
>
> Refer to the [In-App Content Blocks](https://documentation.bloomreach.com/engagement/docs/in-app-content-blocks) user guide for instructions on how to create in-app content blocks in Engagement.

![In-app content blocks in the example app](https://raw.githubusercontent.com/exponea/exponea-flutter-sdk/main/Documentation/images/in-app-content-blocks.png)

## Integration

You can integrate in-app content blocks by adding one or more placeholder views in your app. Each in-app content block must have a `Placeholder ID` specified in its [settings](https://documentation.bloomreach.com/engagement/docs/in-app-content-blocks#3-fill-the-settings) in Engagement. The SDK will display an in-app content block in the corresponding placeholder in the app if the current app user matches the target audience.

### Add a Placeholder View

Add a placeholder view with the specified `placeholderId` to your layout:

```dart
InAppContentBlockPlaceholder(
  placeholderId: "example_content_block"
)
```

After the SDK [initializes](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#initialize-the-sdk), it will identify any in-app content blocks with matching placeholder ID and select the one with the highest priority to display within the placeholder view.

> 📘
>
> Refer to [in_app_cb_page.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/example/lib/page/in_app_cb_page.dart) in the [example app](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-example-app) for a reference implementation.

> 👍
>
> Always us descriptive, human-readable placeholder IDs. They are tracked as an event property and can be used for analytics within Engagement.

## Tracking

The SDK automatically tracks `banner` events for in-app content blocks with the following values for the `action` event property:

- `show`
  In-app content block displayed to user.
- `action`
  User clicked on action button inside in-app content block. The event also contains the corresponding `text` and `link` properties.
- `close`
  User clicked on close button inside in-app content block.
- `error`
  Displaying in-app content block failed. The event contains an `error` property with an error message.

> ❗️
>
> The behavior of in-app content block tracking may be affected by the tracking consent feature, which in enabled mode requires explicit consent for tracking. Refer to the [consent documentation](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking-consent) documentation for details.

## Customization

### Prefetch In-App Content Blocks

The SDK can only display an in-app content block after it has been fully loaded (including its content, any images, and its height). Therefore, the in-app content block may only show in the app after a delay.

You may prefetch in-app content blocks for specific placeholders to make them display as soon as possible.

```dart
final _plugin = ExponeaPlugin();
...
final config = ExponeaConfiguration(
    ...
    inAppContentBlockPlaceholdersAutoLoad: ['placeholder_1'],
    ...
);
final configured = await _plugin.configure(config);
```

### Customize Action Behavior

When an in-app content block action (show, click, close, error) is performed, by default, the SDK tracks the appropriate event and, in case of a button click, opens a link.

You can override or customize this behavior by setting `overrideDefaultBehavior` parameter to `true` and setting callbacks on the `InAppContentBlockPlaceholder`.

The example below calls the original tracking methods. This is recommended but not required.

```dart
InAppContentBlockPlaceholder(
  placeholderId: 'example_content_block',
  overrideDefaultBehavior: true,
  onMessageShown: (placeholderId, contentBlock) {
    //track 'show' event.
    _plugin.trackInAppContentBlockShown(placeholderId, contentBlock);
    print("Content block shown: $contentBlock");
  },
  onNoMessageFound: (placeholderId) {
    print('Content block for $placeholderId not found');
    // you may set this placeholder hidden
  },
  onActionClicked: (placeholderId, contentBlock, action) {
    _plugin.trackInAppContentBlockClick(placeholderId, contentBlock, action);

    // content block action has to be handled for given `action.url`
    handleUrlByYourApp(action.url);
  },
  onCloseClicked: (placeholderId, contentBlock) {
    //track 'close' event.
    _plugin.trackInAppContentBlockClose(placeholderId, contentBlock);
    // placeholder may show another content block if is assigned to placeholder ID
  },
  onError: (placeholderId, contentBlock, errorMessage) {
    _plugin.trackInAppContentBlockError(placeholderId, contentBlock, errorMessage);
    // you may set this placeholder hidden and do any fallback
  },
)
```

### Technical Limitations of In-App Content Blocks Usage in Flutter Apps

In-app content blocks use PlatformViews, where the size is determined by Flutter's widget tree and not by their content size. To mitigate this limitation, the SDK initializes each in-app content block at the beginning with height=1. After it finishes loading the content, it calculates and updates the size. 

When using in-app content blocks in scrollable content, we recommend using in-app content blocks in Views, where the state of widgets is maintained even when the widgets are off-screen.

``` dart
SingleChildScrollView(
  child: Column(
    children: [
      ListItem()
      ...
      InAppContentBlockPlaceholder(
        placeholderId: 'example'
      )
      ...
      ListItem()
    ],
  ),
),
```

## Troubleshooting

This section provides helpful pointers for troubleshooting in-app content block issues.

> 👍 Enable Verbose Logging
> The SDK logs a lot of information in verbose mode while loading in-app content blocks. When troubleshooting in-app content block issues, first ensure to [set the SDK's log level](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#log-level) to `verbose`.

### In-App Content Block Not Displayed

- The SDK can only display an in-app content block after it has been fully loaded (including its content, any images, and its height). Therefore, the in-app content block may only show in the app after a delay.
- Always ensure that the placeholder IDs in the in-app content block configuration (in the Engagement web app) and in your mobile app match.

### In-App Content Block Shows Incorrect Image

- To reduce the number of API calls and fetching time of in-app content blocks, the SDK caches the images contained in content blocks. Once the SDK downloads an image, an image with the same URL may not be downloaded again. If a content block contains a new image with the same URL as a previously used image, the previous image is displayed since it was already cached. For this reason, we recommend always using different URLs for different images.

### Log Messages

While troubleshooting in-app content block issues, you can find useful information in the messages logged by the SDK at verbose log level.

Please refer to the [Android](https://documentation.bloomreach.com/engagement/docs/android-sdk-in-app-content-blocks#log-messages) and [iOS](https://documentation.bloomreach.com/engagement/docs/ios-sdk-in-app-content-blocks#log-messages) documentation for the relevant log messages for each platform.
    