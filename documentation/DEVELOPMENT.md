# Package development guide
Package consists of flutter code in `/lib` folder, Android native module implementation in `/android` and native iOS module in `/ios`. To see SDK functionality in action, we have built an example application you can find in `/example`.

## Flutter
* We use [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) to run unit tests. Use `flutter test` to run unit tests.

## Android
Android native module is written in Kotlin, since that's also used for our native SDK. 
* We use [JUnit4](https://junit.org/junit4/) to run unit tests. Use `./gradlew test` to run unit tests.

## iOS
iOS native module is written in Swift, since that's also used for our native SDK. 

* We use [cocoapods](https://cocoapods.org/) to manage dependencies. You'll see a `Podfile` that defines dependencies for "standalone" XCode project that we use to develop iOS native module. These pods won't be part of released package, `.podspec` file is located at package level. Run `pod install` before opening XCode project and starting development.
* We use [quick](https://github.com/Quick/Quick) to write tests, you can run them directly in XCode.


## Example application
To test and showcase the functionality of the SDK, we provide an example application in `/example`. Example application is linked to the package directly, but there are some caveats.
* When making changes to iOS native module, you sometimes need to reinstall the dependency for example app with `pod install` in `example/ios`

### Running example application
1. `cd example`
2. if you want to try an iOS app then run `pod install` in `example/ios` to install dependencies for ios application.
2. Connect Android or iOS device.
4. `flutter run` to build and run the Android/iOS application. 
