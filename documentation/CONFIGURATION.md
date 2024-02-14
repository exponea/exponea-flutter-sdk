# Configuration
Before using most of the SDK functionality, you'll need to configure Exponea to connect it to backend application.

> You can find your credentials in [Exponea web application](./EXPONEA_CONFIGURATION.md)

Minimal required configuration is simple:
```dart
import 'package:exponea/exponea.dart';

final _plugin = ExponeaPlugin();
final configuration = ExponeaConfiguration(
  projectToken: 'your-project-token',
  authorizationToken: 'your-authorization-token',
  // default baseUrl value is https://api.exponea.com
  baseUrl: 'https://your-exponea-instance.com', 
);
_plugin.configure(configuration)
    .catchError((error) => print('Error: $error'));
```

## Only configure Exponea once
Flutter application code can be reloaded without restarting the native application itself, which speeds up the development process, but it also means that native code usually continues to run as if nothing happens. You should only configure the SDK once, when developing with hot reload enabled, you should check ExponeaPlugin().isConfigured() before configuring Exponea SDK.

Example
```dart
Future<void> configureExponea(ExponeaConfiguration configuration) {
  try {
    if (!await _plugin.isConfigured()) {
      _plugin.configure(configuration);
    } else {
      print("Exponea SDK already configured.");
    }
  } catch (error) {
    print('Error: $error');
  }
}
```

## Configuration object
You can see the dart definition for Configuration object at [lib/src/data/model/configuration.dart](../lib/src/data/model/configuration.dart)

* **projectToken** Default project token used for communication with Exponea backend.

* **authorizationToken** Default authorization token used for communication with Exponea backend. Make sure the token belongs to **public** group and that it has all permissions you need in your application.

* **baseUrl** Base url of your Exponea deployment. Default is https://api.exponea.com

* **projectMapping** In case you would like to track some events to a different Exponea project, you can define mapping between event types and Exponea projects. An event is always tracked to the default project + all projects based on this mapping.
  ``` typescript
  projectMapping: {
    EventType.banner: [
      ExponeaProject(
        projectToken: 'other-project-token',
        authorizationToken: 'other-auth-token',
      ),
    ],
  }
  ```
* **defaultProperties** You can define default properties that will be added to every event you track to Exponea. 
  Useful for constants like application settings.
  You can change these properties at runtime calling `ExponeaPlugin().setDefaultProperties()`
  
* **flushMaxRetries** Events are tracked into Exponea SDK internal database and flushed once the device has internet connection. This process may still fail, this property allows you to set number of retries in case that happens.

* **sessionTimeout** When the application is closed, the SDK doesn't track end of session right away, but waits a bit for the user to come back before doing so. You can configure the timeout by setting this property.

* **automaticSessionTracking** By default, the SDK tracks sessions for you. You can opt-out and implement your own session tracking.

* **pushTokenTrackingFrequency** 
  * Defines how often should the SDK track push notification token to Exponea
  * Default value is `TokenFrequency.onTokenChange` and is recommended.
  * Possible values:
	  * `.onTokenChange` - tracks push token if differs from previous tracked one
	  * `.everyLaunch` - tracks push token always
	  * `.daily` - tracks push token once per day

* **advancedAuthEnabled** If true, Customer Token authentication is used for communication with BE for API listed in [Authorization](./AUTHORIZATION.md) document.

* **inAppContentBlockPlaceholdersAutoLoad** Automatically load content of In-app content blocks assigned to these Placeholder IDs

* **android** Specific configuration for Android

* **ios** Specific configuration for iOS

### Android specific configuration
* **automaticPushNotifications** By default Exponea SDK will setup a Firebase service and try to automatically process push notifications coming from Exponea backend. You can opt-out setting this to `false`.

* **pushIcon** Android resource id of the icon to be used for push notifications.

* **pushAccentColor** Accent color of push notification icon and buttons

* **pushChannelName?** Channel name for push notifications. Only for API level 26+

* **pushChannelDescription** Channel description for push notifications. Only for API level 26+

* **pushChannelId** Channel ID for push notifications. Only for API level 26+

* **pushNotificationImportance** Notification importance for the notification channel. Only for API level 26+

* **httpLoggingLevel** Level of HTTP request/response logging

### iOS specific configuration
* **requirePushAuthorization** If true, push notification registration and push token tracking is only done if the device is authorized to display push notifications. Unless you're using silent notifications, keep the default value `true`.

* **appGroup** App group used for communication between main app and notification extensions. This is a required field for Rich push notification setup


## Exponea properties
  
### Logging
When debugging, it's useful to set Exponea SDK to `VERBOSE` logging. You can do so by setting `ExponeaPlugin().setLogLevel(LogLevel.verbose)`
  
### Flushing
Learn more about flushing setup in **Flushing data** section of [Tracking guide](./TRACKING.md#flushing-data)
