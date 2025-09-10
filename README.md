# Flutter Exponea SDK
Flutter Exponea SDK allows your application to interact with the [Bloomreach Engagement](https://www.bloomreach.com/) Customer Data & Experience Platform. Exponea empowers B2C marketers to raise conversion rates, improve acquisition ROI, and maximize customer lifetime value.

Flutter SDK is implemented as a wrapper around [native Android SDK](https://github.com/exponea/exponea-android-sdk) and [native iOS SDK](https://github.com/exponea/exponea-ios-sdk).

> Bloomreach Engagement was formerly known as Exponea. For backward compatibility, the Exponea name continues to be used in the Flutter SDK.

## Getting started
In your projects `pubspec.yaml` file, add dependency to Flutter Exponea SDK:
```
exponea: x.y.z
```

### iOS setup

* `$ cd ios`
* `$ pod install`

Minimal supported iOS version for Exponea SDK is 13.0, you may need to change iOS version on the first line of your `ios/Podfile` to `platform :ios, '13.0'`, or higher.

### Android setup
You'll most likely need to enable multidex. Edit `android/app/build.gradle` and add `multiDexEnabled true` to android defaultConfig.
```
android {
    ...
    defaultConfig {
        ...
        multiDexEnabled true
    }
```

Minimal supported Android API level for Exponea SDK is 21.

## Documentation

- [Initial SDK Setup](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup)
  - [Configuration](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration)
  - [Authorization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization)
  - [Data Flushing](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-data-flushing)
- [Basic Concepts](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-basic-concepts)
- [Tracking](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking)
  - [Tracking Consent](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking-consent)
- [Links](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-links)
- [Push Notifications](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications)
  - [Android Push Notifications](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-android)
  - [iOS Push Notifications](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-ios)
- [Fetch Data](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-fetch-data)
- [In-App Personalization](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-in-app-personalization)
  - [In-App Messages](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-in-app-messages)
  - [In-App Content Blocks](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-in-app-content-blocks)
- [App Inbox](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-app-inbox)
- [Example App](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-example-app)
- [Development](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-development)
- [Release Notes](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-release-notes)
   - [SDK Version Update Guide](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-version-update)

If facing any issues, look for **Troubleshooting** section in the respective document.

## Release Notes

[Release notes](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-release-notes) for the SDK.


## Support

Are you a Bloomreach customer and dealing with some issues on mobile SDK? You can reach the official Engagement Support [via these recommended ways](https://documentation.bloomreach.com/engagement/docs/engagement-support#contacting-the-support).

Note that Github repository issues and PRs will also be considered but with the lowest priority and without guaranteed output.

- [Mobile SDK tracking FAQ](https://support.bloomreach.com/hc/en-us/articles/18153058904733-Mobile-SDK-tracking-FAQ) at Bloomreach Support Help Center
- [Mobile push notifications FAQ](https://support.bloomreach.com/hc/en-us/articles/18152713374877-Mobile-Push-Notifications-FAQ) at Bloomreach Support Help Center
- [In-app messages FAQ](https://support.bloomreach.com/hc/en-us/articles/18152718785437-In-App-Messages-FAQ) at Bloomreach Support Help Center
