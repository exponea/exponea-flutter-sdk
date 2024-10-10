---
title: SDK development
excerpt: Work with the Flutter SDK source code.
slug: flutter-sdk-development
categorySlug: integrations
parentDocSlug: flutter-sdk
---

## SDK development guide

The project consists of Flutter code in the `/lib` folder, a native Android module in `/android`, and a native iOS module in `/ios`. To see SDK functionality in action, we provide an [example application](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-example-app) you can find in `/example`.

### Flutter

* We use [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) to run unit tests. Use `flutter test` to run unit tests.

### Android

The Android native module is written in Kotlin, since that's also used for our native [Android SDK](https://documentation.bloomreach.com/engagement/docs/android-sdk).

* We use [JUnit4](https://junit.org/junit4/) to run unit tests. Use `./gradlew test` to run unit tests.

### iOS

The iOS native module is written in Swift, since that's also used for our native [iOS SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk).

* We use [CocoaPods](https://cocoapods.org/) to manage dependencies. You'll see a `Podfile` that defines dependencies for the "standalone" Xcode project that we use to develop the iOS native module. These pods won't be part of the released package, the `.podspec` file is located at package level. Run `pod install` before opening the Xcode project and starting development.
* We use [quick](https://github.com/Quick/Quick) to write tests, you can run them directly in XCode.
