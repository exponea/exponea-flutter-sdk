# Anonymize customer

Anonymize is a feature that allows you to switch users. Typical use-case is user login/logout.

Anonymize will delete all stored information and reset the current customer. New customer will be generated, install and session start events tracked. Push notification token from the old user will be wiped and tracked for the new user, to make sure the device won't get duplicate push notifications.

```dart
import 'package:exponea/exponea.dart';

final _plugin = ExponeaPlugin();
_plugin.anonymize();
```

> Keep in mind that invoking of `anonymize` will remove also a Push notification token from storage. To load a current token, your application should retrieve a valid token manually before using any Push notification feature. So it may be called right after `anonymize` or before/after `identifyCustomer`, it depends on your Push notifications usage.
> Guide how to retrieve a valid Push notification token is written for [Android](./PUSH_ANDROID.md) and [iOS](./PUSH_IOS.md).

### Project settings switch
Anonymize also allows you to switch to a different project, keeping the benefits described above. New user will have the same events as if the app was installed on a new device.

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
