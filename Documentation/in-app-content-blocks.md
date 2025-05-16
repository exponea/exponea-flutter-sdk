---
title: In-app content blocks
excerpt: Display native in-app content blocks based on definitions set up in Engagement using the Flutter SDK
slug: flutter-sdk-in-app-content-blocks
categorySlug: integrations
parentDocSlug: flutter-sdk-in-app-personalization
---

In-app content blocks provide a way to display campaigns within your mobile applications that seamlessly blend with the overall app design. Unlike [in-app messages](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-in-app-messages) that appear as overlays or pop-ups demanding immediate attention, in-app content blocks display inline with the app's existing content.

You can strategically position placeholders for in-app content blocks within your app. You can customize the behavior and presentation to meet your specific requirements.

> 📘
>
> Refer to the [In-app content blocks](https://documentation.bloomreach.com/engagement/docs/in-app-content-blocks) user guide for instructions on how to create in-app content blocks in Engagement.

![In-app content blocks in the example app](https://raw.githubusercontent.com/exponea/exponea-flutter-sdk/main/Documentation/images/in-app-content-blocks.png)

## Integration

You can integrate in-app content blocks by adding one or more placeholder views in your app. Each in-app content block must have a `Placeholder ID` specified in its [settings](https://documentation.bloomreach.com/engagement/docs/in-app-content-blocks#3-fill-the-settings) in Engagement. The SDK will display an in-app content block in the corresponding placeholder in the app if the current app user matches the target audience.

### Add a placeholder view

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

## Integration of a carousel view

If you want to show multiple in-app content blocks to the user for the same `Placeholder ID`, consider using `InAppContentBlockCarousel`. The SDK will display the in-app content blocks for the current app user in a loop, in order of `Priority`. The in-app content blocks are displayed in a loop until the user interacts with them or until the carousel view instance is reloaded programmatically.

If the carousel view's placeholder ID only matches a single in-app content block, it will behave like a static placeholder view with no loop effect.

### Add a carousel view

Add a carousel view with the specified `placeholderId` to your layout:

```dart
InAppContentBlockCarousel(
  placeholderId: 'example_carousel',
  scrollDelay: 5, // delay in seconds between automatic scroll; 0 for no scroll; default value is 3
  maxMessagesCount: 5, // max count of visible content blocks; 0 for show all; default value is 0
)
```

> 📘
>
> Refer to [in_app_cb_carousel_page.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/example/lib/page/in_app_cb_carousel_page.dart) in the [example app](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-example-app) for a reference implementation.

> 👍
>
> Always us descriptive, human-readable placeholder IDs. They are tracked as an event property and can be used for analytics within Engagement.

## Tracking

The SDK automatically tracks `banner` events for in-app content blocks with the following values for the `action` event property:

- `show`
  In-app content block displayed to user.
- Event is tracked everytime if Placeholder view is used. Carousel view tracks this event only if content block is shown for first time after
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

### Prefetch in-app content blocks

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

### Customize action behavior

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

### Handle carousel presentation status

You can register a multiple callbacks to a carousel view instance to retrieve information for each update and/or change behaviour by setting the `trackActions` and `overrideDefaultBehavior` flags.

* trackActions
  * If `false`, events "close" and "click" on banners won't be tracked by the SDK. Events "show" and "error" are tracked regardless from this flag.
  * If `true`, events "close" and "click" are tracked by the SDK.
  * Default behaviour is as with value `true`, all events are tracked by the SDK
* overrideDefaultBehavior
  * If `true`, deep-links and universal links won't be opened by SDK. This does not affect tracking behaviour.
  * If `false`, deep-links and universal links will be opened by SDK.
  * Default behaviour is as with value `false`, action links are opened by SDK.

```dart
InAppContentBlockCarousel(
  placeholderId: 'example_carousel',
  // If overrideDefaultBehavior is set to true, default action will not be performed (deep link, universal link, etc.)
  overrideDefaultBehavior: false,
  // If trackActions is set to false, click and close in-app content block events will not be tracked automatically
  trackActions: true,
  scrollDelay: 5, // delay in seconds between automatic scroll; 0 for no scroll; default value is 3
  maxMessagesCount: 5, // max count of visible content blocks; 0 for show all; default value is 0
  onMessageShown: (placeholderId, contentBlock, index, count) {
    // This is triggered on each scroll so 'contentBlock' parameter represents currently shown content block,
    // so as 'index' represents position index of currently shown content block
  },
  onMessagesChanged: (count, contentBlocks) {
    // This is triggered after 'reload' or if a content block is removed because interaction has been done
    // and message has to be shown until interaction.
  },
  onNoMessageFound: (placeholderId) {
    // This is triggered after `reload` when no content block has been found for a given placeholder.
  },
  onError: (placeholderId, contentBlock, errorMessage) {
    // This is triggered when an error occurs while loading or showing of content block.
    // Parameter `contentBlock` is the content block which caused the error or undefined in case of general problem.
    // Parameter `errorMessage` is the error message that describes the problem.
  },
  onCloseClicked: (placeholderId, contentBlock) {
    // This is triggered when a content block is closed.
  },
  onActionClicked: (placeholderId, contentBlock, action) {
    // This is triggered when a content block action is clicked.
    // Parameter `action` contains the action information.
  },
)
```

### Customize carousel view filtration and sorting

A carousel view filters available content blocks in the same way as a placeholder view:

- The content block must meet the `Schedule` setting configured in the Engagement web app
- The content block must meet the `Display` setting configured in the Engagement web app
- The content must be valid and supported by the SDK

The order in which content blocks are displayed is determined by:

1. By the `Priority` setting, descending
2. By the `Name`, ascending (alphabetically)

You can implement additional filtration and sorting by registering your own `filterContentBlocks` and `sortContentBlocks` on the carousel view instance:

```dart
InAppContentBlockCarousel(
  placeholderId: 'example_carousel',
  filterContentBlocks: (contentBlocks) {
    // if you want keep default filtration, do not register this method
    // you can add your own filtration, for example ignore any item named "discarded"
    return contentBlocks.where((block) => block.name != 'discarded').toList();
  },
  sortContentBlocks: (contentBlocks) {
    // if you want to keep default sort, do not register this method
    // you can bring your own sorting, for example reverse default sorting result
    return contentBlocks.reversed.toList();
  },
)
```

> ❗️
>
> A carousel view accepts the results from the filtration and sorting implementations. Ensure that you return all wanted items as result from your implementations to avoid any missing items.

> ❗️
>
> A carousel view can be configured with `maxMessagesCount`. Any value higher than zero applies a maximum number of content blocks displayed, independently of the number of results from filtration and sorting methods. So if you return 10 items from filtration and sorting method but `maxMessagesCount` is set to 5 then only first 5 items from your results.

### Technical limitations of in-app content blocks usage in Flutter apps

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

> 👍 Enable verbose logging
> The SDK logs a lot of information in verbose mode while loading in-app content blocks. When troubleshooting in-app content block issues, first ensure to [set the SDK's log level](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#log-level) to `verbose`.

### In-app content block not displayed

- The SDK can only display an in-app content block after it has been fully loaded (including its content, any images, and its height). Therefore, the in-app content block may only show in the app after a delay.
- Always ensure that the placeholder IDs in the in-app content block configuration (in the Engagement web app) and in your mobile app match.

### In-app content block shows incorrect image

- To reduce the number of API calls and fetching time of in-app content blocks, the SDK caches the images contained in content blocks. Once the SDK downloads an image, an image with the same URL may not be downloaded again. If a content block contains a new image with the same URL as a previously used image, the previous image is displayed since it was already cached. For this reason, we recommend always using different URLs for different images.

### Log messages

While troubleshooting in-app content block issues, you can find useful information in the messages logged by the SDK at verbose log level.

Please refer to the [Android](https://documentation.bloomreach.com/engagement/docs/android-sdk-in-app-content-blocks#log-messages) and [iOS](https://documentation.bloomreach.com/engagement/docs/ios-sdk-in-app-content-blocks#log-messages) documentation for the relevant log messages for each platform.
    