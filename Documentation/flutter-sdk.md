---
title: Flutter SDK
slug: flutter-sdk
category:
  uri: /branches/2/categories/guides/Developers
content:
  excerpt: Exponea SDK for Flutter
---

> 📘 
> 
> {user.mkg} was formerly known as Exponea. For backward compatibility, the Exponea name continues to be used in the Flutter SDK.

## What is the Exponea Flutter SDK?

The Exponea Flutter SDK lets you integrate your Flutter-based mobile application with {user.mkg} and track your customers' behavior in your app. Integrating the SDK in your app enables tracking events and customer properties, sending push notifications, and displaying in-app messages and content blocks.

The SDK supports two integration modes: the standard **{user.mkg} project** integration using a project token and API key, and the **{user.dh} [event streams](https://documentation.bloomreach.com/data-hub/docs/event-streams)** integration using a stream ID and JWT-based authentication.

The Flutter SDK is implemented as a wrapper around the native [Android](https://documentation.bloomreach.com/engagement/docs/android-sdk) and [iOS](https://documentation.bloomreach.com/engagement/docs/ios-sdk) SDKs.

The SDK is [available as open source on GitHub](https://github.com/exponea/exponea-flutter-sdk) for maximum transparency and includes an [Example app for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-example-app) you can use as a reference implementation.

> ❗️
> 
> Always make sure to capture explicit consent before using the SDK to track and collect data.

## Video tutorial

This short video guide provides a step-by-step introduction to integrating the Flutter SDK into your app.

<iframe src="//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fwww.youtube.com%2Fembed%2FY-qxCVHOG44%3Ffeature%3Doembed&display_name=YouTube&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DY-qxCVHOG44&image=https%3A%2F%2Fi.ytimg.com%2Fvi%2FY-qxCVHOG44%2Fhqdefault.jpg&key=7788cb384c9f4d5dbbdbeffd9fe4b92f&type=text%2Fhtml&schema=youtube" width="854" height="480" scrolling="no" title="YouTube embed" frameBorder="0" allow="autoplay; fullscreen; encrypted-media; picture-in-picture;" allowFullScreen={true}></iframe>

## Get started

- [Initial setup for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup)
  - [Configuration for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-configuration)
  - [Authorization for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-authorization)
  - [Data flushing for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-data-flushing)
- [Basic concepts for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-basic-concepts)
- [Tracking for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking)
  - [Tracking consent for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-tracking-consent)
- [Links for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-links)
- [Push notifications for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-notifications)
  - [Android push notifications for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-android)
  - [iOS push notifications for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-push-ios)
- [Fetch data for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-fetch-data)
- [In-app personalization for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-in-app-personalization)
  - [In-app messages for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-in-app-messages)
  - [In-app content blocks for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-in-app-content-blocks)
- [App Inbox for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-app-inbox)
- [Example app for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-example-app)
- [Development for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-development)
- [Release notes for Flutter SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-release-notes)
  - [Flutter SDK version update guide](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-version-update)

## Frequently asked questions

- [Mobile SDK tracking FAQ](https://support.bloomreach.com/hc/en-us/articles/18153058904733-Mobile-SDK-tracking-FAQ) at {user.br} Support Help Center
- [Mobile push notifications FAQ](https://support.bloomreach.com/hc/en-us/articles/18152713374877-Mobile-Push-Notifications-FAQ) at {user.br} Support Help Center
- [In-app messages FAQ](https://support.bloomreach.com/hc/en-us/articles/18152718785437-In-App-Messages-FAQ) at {user.br} Support Help Center
