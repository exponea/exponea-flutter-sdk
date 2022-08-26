# Flutter Exponea SDK
Flutter Exponea SDK allows your application to interact with the [Exponea](https://exponea.com/) Customer Data & Experience Platform. Exponea empowers B2C marketers to raise conversion rates, improve acquisition ROI, and maximize customer lifetime value.

Flutter SDK is implemented as a wrapper around [native Android SDK](https://github.com/exponea/exponea-android-sdk) and [native iOS SDK](https://github.com/exponea/exponea-ios-sdk).

## Getting started
In your projects `pubspec.yaml` file, add dependency to Flutter Exponea SDK:
```
exponea: x.y.z
```

### iOS setup

* `$ cd ios`
* `$ pod install`

Minimal supported iOS version for Exponea SDK is 10.3, you may need to change iOS version on the first line of your `ios/Podfile` to `platform :ios, '10.3'`, or higher.

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
  * [Basics concepts](./documentation/BASIC_CONCEPTS.md)
  * [Configuration](./documentation/CONFIGURATION.md)
  * [Tracking](./documentation/TRACKING.md)
  * [Tracking Campaigns(Android App Links/Universal links)](./documentation/LINKING.md)
  * [Fetching](./documentation/FETCHING.md)
  * [Push notifications](./documentation/PUSH.md)
  * [Anonymize customer](./documentation/ANONYMIZE.md)
  * [In-app messages](./documentation/IN_APP_MESSAGES.md)
  * [Example/Package development documentation](./documentation/DEVELOPMENT.md) - Learn how to build example application or the package itself
  * [SDK version update guide](./documentation/VERSION_UPDATE.md)

If facing any issues, look for **Troubleshooting** section in the respective document.

## Release Notes

[Release notes](./CHANGELOG.md) for the SDK.
