---
title: Example app
excerpt: Build, run, and navigate the example app included with the Flutter SDK
slug: flutter-sdk-example-app
categorySlug: integrations
parentDocSlug: flutter-sdk
---

The Exponea Flutter SDK includes an example application you can use as a reference implementation. You can build and run the app, test Engagement features, and compare the code and behavior of your implementation with the expected behavior and code in the example app.

## Prerequisites

You must have the following software installed to be able to build and run the example app:

- [Flutter SDK](https://docs.flutter.dev/tools/sdk)
- [Git](https://git-scm.com/)
- [Android Studio](https://developer.android.com/studio) with a virtual or physical device set up to run the app on Android
- [Xcode](https://developer.apple.com/xcode/) and [CocoaPods](https://cocoapods.org/) with a virtual or physical device set up to run the app on iOS

> 👍
>
> Follow Flutter's [Get started](https://docs.flutter.dev/get-started/install) guide if you are new to Flutter.

## Build and run the example app

1. Clone the [exponea-flutter-sdk](https://github.com/exponea/exponea-flutter-sdk) repository on GitHub:
   ```shell
   git clone https://github.com/exponea/exponea-flutter-sdk.git
   ```
2. Enter the `example` directory containing the example app:
   ```shell
   cd exponea-flutter-sdk/example
   ```
3. To run the app on iOS:
   1. Run CocoaPods in the `ios` directory to install dependencies:
      ```shell
      cd ios
      pod install
      cd ..
      ```
   2. Connect a virtual or physical iOS device.
   3. Run the app:
      ```shell
      flutter run
      ```
4. To run the app on Android:
   1. Connect a virtual or physical Android device.
   2. Run the app:
      ```shell
      flutter run --flavor gms
      ```
      Alternatively, use `--flavor hms` for Huawei devices without GooglePlay services but with HMS Core.
      > 👍
      >
      > If you use Visual Studio Code, you can create a [launch configuration](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations) to use the flavor flag.

> 📘
>
> To enable push notifications in the example app, you must also configure the [Firebase integration](https://documentation.bloomreach.com/engagement/docs/android-sdk-configure-firebase) or [Huawei integration](https://documentation.bloomreach.com/engagement/docs/android-sdk-configure-huawei) in the Exponea web app.

## Navigate the example app

![Example app screens (iOS)](https://raw.githubusercontent.com/exponea/exponea-flutter-sdk/main/Documentation/images/example-app-flutter-ios.png)

When you run the app in the simulator, you'll see the **ConfigPage**. Enter your [project token, API token, and API base URL](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management). Optionally, disable `Automatic Session Tracking` using the switch (default enabled). Then click `Configure` to [initialize the SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#initialize-the-sdk).
> [`config.dart`](https://github.com/exponea/exponea-flutter-sdk/blob/main/example/lib/page/config.dart)

The **HomePage** provides several buttons to test the different SDK features.
> [`home.dart`](https://github.com/exponea/exponea-flutter-sdk/blob/main/example/lib/page/home.dart)

- In the `Push events` section, you can `Request Push Authorization` and check whether push notifications are `Configured?`.

- In the `Customer` section, you can get the customer's soft ID (`Get Cookie`), `Identify` the customer (using the hardcoded ID `test-user-1@test.com`), or `Anonymize` the customer.

- In the `Fetch` section, you can fetch the customer's `Consents` and `Recommendations`.

- In the `Flush Mode` section, you can `Get` and `Set` the flush mode, and trigger a manual `Flush`.

- In the `Flush Period` section, you can configure the flush period using the slider and the `Set` button.

- In the `Track` section, you can track an `Event` (a harcoded event `event_name` with some sample properties) and, if you disabled automatic session tracking, you can manually track `Session Start` and `Session End`.

- In the `Trigger in-app messages by event` section, you can track various test events you can use to trigger in-app messages while testing:
  - `Modal` (track a `test_msg_modal` event)
  - `Fullscreen` (track a `test_msg_fullscreen` event)
  - `Slide-in` (tracks a `test_msg_slide` event)
  - `Alert` (tracks a `test_msg_alert` event)

- In the `Log Level` section, you can `Get` the current log level.

- In the `App Inbox` section, you can access the `App Inbox`, `Fetch all` messages, `Fetch first` message, and `Mark first as read`.

- Using the `In App CB Example Page` button, you can access the **InAppCbPage** to test in-app content blocks. Use the placeholder IDs `example_top` and `example_list` for the corresponding placeholders. Use the placeholder IDs `ph_x_example_iOS` and `ph_x_example_Android` to test platform-specific content blocks in the placeholder labeled "platformSpecificPlaceholderId".
  > [in_app_cb_page.dart](https://github.com/exponea/exponea-flutter-sdk/blob/main/example/lib/page/in_app_cb_page.dart)

Try out the different features in the app, then find the customer profile in the Engagement web app (under `Data & Assets` > `Customers`) to see the properties and events tracked by the SDK.

By default, the customer is tracked anonymously using a cookie soft ID. You can look up the cookie value in the logs and find the corresponding profile in the Engagement web app.

If you used the `Identify` button, the customer can be found in Engagement web app by the test email address (`test-user-1@test.com`).

> 📘
>
> Refer to [Customer Identification](https://documentation.bloomreach.com/engagement/docs/customer-identification) for more information on soft IDs and hard IDs.

![Example app screens (Android)](https://raw.githubusercontent.com/exponea/exponea-flutter-sdk/main/Documentation/images/example-app-flutter-android.png)

## Troubleshooting

If you encounter any issues running the example app, the following may help:

- In the `example` directory, run `flutter clean`, then `flutter pub get`.
- If the app doesn't start on Android, you may have forgotten to include the `--flavor gms` or `--flavor hms` flag.