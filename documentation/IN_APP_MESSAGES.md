## In-app messages
Exponea SDK allows you to display native in-app messages based on definitions set up on Exponea web application. You can find information on how to create your messages in [Exponea documentation](https://docs.exponea.com/docs/in-app-messages).

No developer work is required for in-app messages, they work automatically after the SDK is configured.

> The behaviour of InApp messages tracking (action click and message close) may be affected by the tracking consent feature, which in enabled mode considers the requirement of explicit consent for tracking. Read more in [tracking consent documentation](https://documentation.bloomreach.com/engagement/docs/configuration-of-tracking-consent).

### Troubleshooting
As with everything that's supposed works automatically, the biggest problem is what to do when it doesn't.

#### Logging
The SDK logs a lot of useful information about presenting in-app messages in `verbose` mode. To see why each individual message was/wasn't displayed, set `ExponeaPlugin().setLogLevel(LogLevel.verbose)` before configuring the SDK.

#### Displaying in-app messages
In-app messages are triggered when an event is tracked based on conditions setup on Exponea backend. Once a message passes those filters, the SDK will try to present the message.

* On **iOS**, the message will be presented in the top-most `presentedViewController` (except for slide-in message that uses `UIWindow` directly).
* On **Android**, the message will be presented in a new activity(except for slide-in message that is injected into current activity).

If your application decides to present another UIViewController/start a new Activity right at the same time a race condition is created and the message might be displayed and immediately dismissed. Keep this in mind if the logs tell you your message was displayed but you don't see it.

> Show on `App load` displays in-app message when a `session_start` event is tracked. If you close and quickly reopen the app, it's possible that the session did not timeout and message won't be displayed. If you use manual session tracking, the message won't be displayed unless you track `session_start` event yourself.

### Custom in-app message actions
If you want to override default SDK behavior, when in-app message action is performed (button is clicked, a message is closed), or you want to add your code to be performed along with code executed by the SDK, you can set up a listener for `inAppMessageAction` using `ExponeaPlugin.inAppMessageActionStream({bool overrideDefaultBehavior = false, bool trackActions = true})`. You can override default behavior of SDK with `overrideDefaultBehavior` and `trackActions` parameters. If overrideDefaultBehavior is set to true, default in-app action will not be performed ( e.g. deep link ). If trackActions is set to false, click and close in-app events will not be tracked automatically.
The SDK will hold last inAppMessageAction and call the listener once it's set, but it's still recommended to set the listener as soon as possible.

```dart
// If overrideDefaultBehavior is set to true, default in-app action will not be performed ( e.g. deep link )
const overrideDefaultBehavior = false;
// If trackActions is set to false, click and close in-app events will not be tracked automatically
const trackActions = true;
final subscription = _plugin.inAppMessageActionStream(overrideDefaultBehavior: overrideDefaultBehavior, trackActions: trackActions).listen((inAppMessageAction) {
  print(inAppMessageAction);
});
```

Don't forget to call `subscription.cancel()` when no longer needed. If you cancel subscription from stream, SDK returns back to default behavior (default in-app action will be performed and click and close in-app events will be tracked).
