## In-app content blocks
Exponea SDK allows you to display In-app content blocks based on definitions set up on the Exponea web application. You can find information on creating your messages in [Exponea documentation](https://documentation.bloomreach.com/engagement/docs/in-app-content-blocks)

In-app content block will be shown exactly where you'll place a placeholder UI view. You can register a placeholder view into your layout:

```dart
InAppContentBlockPlaceholder(
  placeholderId: platformSpecificPlaceholderId
)
```

No more developer work is required; they work automatically after the SDK is initialized.
In-app content blocks are shown within placeholder view by its ID automatically based on conditions setup on the Exponea backend. Once a message passes those filters, the SDK will try to present the message.

### If displaying In-app content blocks has delay

Message is able to be shown only if it is fully loaded and also its images are loaded too. In case that message is not yet fully loaded (including its images) then you may experience delayed showing.

If you need to show In-app content block as soon as possible (ideally instantly) you may set a auto-prefetch of placeholders. In-app content blocks for these placeholders are loaded immediately after SDK initialization.

``` dart
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

### In-app content block images caching
To reduce the number of API calls, SDK is caching the images displayed in messages. Therefore, once the SDK downloads the image, an image with the same URL may not be downloaded again, and will not change, since it was already cached. For this reason, we recommend always using different URLs for different images.

### In-app content blocks tracking

In-app content blocks are tracked automatically by SDK. You may see these `action` values in customers tracked events:

- 'show' - event is tracked if message has been shown to user
- 'action' - event is tracked if user clicked on action button inside message. Event contains 'text' and 'link' properties that you might be interested in
- 'close' - event is tracked if user clicked on close button inside message
- 'error' - event is tracked if showing of message has failed. Event contains 'error' property with meaningfull description

> The behaviour of In-app content block tracking may be affected by the tracking consent feature, which in enabled mode considers the requirement of explicit consent for tracking. Read more in [tracking consent documentation](./TRACKING_CONSENT.md).

### Technical limitations of In-app content blocks usage in Flutter app
In-app content blocks use PlatformViews, where the size is determined by Flutter's widget tree and not by their content size. To mitigate this limitation, the In-app content block is initialized at the beginning with height=1. After the load of content is done, the calculation of size is performed and then the size is updated. 

When there is need to use In-app content blocks in scrollable content, we recommend use In-app content blocks in Views, where the state of widgets is maintained even when the widgets are off-screen.

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