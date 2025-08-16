---
title: Release notes
excerpt: Exponea Flutter SDK release notes
slug: flutter-sdk-release-notes
categorySlug: integrations
parentDocSlug: flutter-sdk
---

> 📘
>
> Refer to the [SDK version update guide](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-version-update) for details on updating from version 0.x.x to 1.x.x.

## Release Notes
## Release Notes for 2.1.0

* Added:
  * Adds support for multiple In-App Content Blocks in the same placeholder through InAppContentBlockCarousel. The SDK will loop through the content blocks one at a time in order of the configured Priority.
  * Adds support for AppInboxDetailView and AppInboxListView as widgets for integrating App Inbox into Flutter apps.
  * Adds requirePushAuthorization, allowWebCookies, and appInboxDetailImageInset Android-specific parameters to the configuration.
  * Adds rich styling support for native in-app messages.
  * Adds Segmentation API feature support
  * Updates native Android SDK to version 4.4.0.
  * Updates native iOS SDK to version 3.5.1.
  * Adds minor documentation improvements.
  * Increases the minimum supported Android API level to 24.
* Fixed:
  * Fixes an issue where, in certain scenarios, the app would crash while parsing In-App message during manual tracking.
  * Fixes and updates some links in the documentation.

## Release Notes for 2.0.0
#### December 13, 2024
* Added:
  * Updates native Android SDK to version 4.0.1.
  * Updates native iOS SDK to version 3.0.1.
  * Updates the default session timeout to 60 seconds.
  * Adds a manualSessionAutoClose configuration parameter to override automatic session end tracking for open sessions when sessionStart is called multiple times.
  * Adds compatibility with Android Gradle Plugin 8.
  * Adds identification of Cancel button clicks in in-app message close events and inclusion of the button label in the tracked event.
  * Adds minor documentation improvements.
* Fixed:
  * Fixes an issue on iOS where an empty App Inbox caused click events to be passed to the underlying app.
  * Fixes an issue where, in certain scenarios, the app would crash while parsing Recommendations .

## Release Notes for 1.7.0
#### August 07, 2024
* Added:
  * Introduces improved SDK documentation at documentation.bloomreach.com.
  * Updates native Android SDK to version 3.16.0.
  * Updates native iOS SDK to version 2.28.0.
  * Extends the SDK API with:
    * In-app content block callback and tracking methods
    * In-app message callbacks and tracking methods
    * A method to track payment events
    * Methods related to handling and tracking push notifications
* Fixed:
  * Fixes incorrectly mapped parameters in trackAppInboxClick.
  * Fixes incorrect links and other minor issues in the documentation.

## Release Notes for 1.6.0
#### March 08, 2024
* Features
  * Added In-app messages callback handler to define your customised message action handling
  * Android PUSH notification permission request support
  * Documentation extended with PUSH notification payload structure description, PUSH handling and more
  * Anonymize feature has been described with more details in documentation


## Release Notes for 1.5.0
#### January 29, 2024
* Features
  * In-app content block feature has been added into SDK
  * Dart SDK version increased to 2.17.0
  * Flutter minimal version increased to 3.0.0
* Bug Fixes
  * Fixed: Bad handling of native errors to Flutter ones causes crash
  * Fixed: Wrong data types for App Inbox params showIcon and enabled


## Release Notes for 1.4.2
#### October 11, 2023
* Bug Fixes
  * Fixed: requireNotConfigured() used in isRead and other methods


## Release Notes for 1.4.1
#### August 15, 2023
* Bug Fixes
  * Fixed: Mapping of is_read vs isRead and create_time vs createTime
  * Fixed: Registration of App Inbox button for iOS part


## Release Notes for 1.4.0
#### April 28, 2023
* Features
  * Native SDK updated - Android to 3.5.0
  * Support section added to main Readme

## Release Notes for 1.3.1
#### March 15, 2023
* Bug Fixes
  * Fixed: Parsing pushAccentColor with support of ARGB format
  * Fixed: Handles empty/null push notification data correctly


## Release Notes for 1.3.0
#### March 03, 2023
* Features
  * Added App Inbox feature with PUSH and HTML - Inbox message type support
  * Added support for Customer token authorization


## Release Notes for 1.2.0
#### February 02, 2023
* Features
  * Native SDK updated - Android to 3.2.1 and iOS to 2.13.1
  * Added Configuration flag to be able to disable tracking of default properties along with customer properties
  * Guiding documentation added for Push notification update after certain circumstances
  * Added documentation notes about tracking consent according to DSGVO/GDPR
* Bug Fixes
  * Fixed: Update minimal iOS supported version in doc


## Release Notes for 1.1.0
#### September 02, 2022
* Features
  * Added a support of HTML InApp messages
  * Shows a warn log for developer if old SDK version is used
* Bug Fixes
  * Fixed: Version upgrade guide is linked from README and Release Notes documentations
  * Fixed: License established to MIT
  * Fixed: Duplicated push open action track is not called on app cold start

## Release Notes for 1.0.0
#### March 23, 2022
* Features
  * Flutter SDK upgraded to 2.10
  * Native Android SDK updated to 3.0.3 - [Android SDK Release notes](https://github.com/exponea/exponea-android-sdk/blob/3.0.3/Documentation/RELEASE_NOTES.md)
  * Native iOS SDK updated to 2.11.3 - [iOS SDK Release notes](https://documentation.bloomreach.com/engagement/docs/ios-sdk-release-notes#release-notes-for-2113)

## Release Notes for 0.2.1
#### August 12, 2021
* Fixes
    * Package usage in README.md

## Release Notes for 0.2.0
#### August 12, 2021
* Features
    * Universal links and app links

## Release Notes for 0.1.1
#### July 21, 2021
* Features
    * Telemetry
    * Push notifications for iOS
    * Documentation

## Release Notes for 0.1.0
#### July 8, 2021
* Features
    * Initial release with base functionality of the mobile SDKs - tracking, in-app messages, fetching
    * Push notifications for Android
