---
title: Data Flushing
excerpt: Learn how the Flutter SDK uploads data to the Engagement API and how to customize this behavior
slug: flutter-sdk-data-flushing
categorySlug: integrations
parentDocSlug: flutter-sdk-setup
---

## Data Flushing
The SDK caches data (sessions, events, customer properties, etc.) in an internal database and periodically sends it to the Engagement API. After the data has been uploaded, the values in the Engagement web app are updated, and the cached data is removed from the SDK's internal database. This process is called **data flushing**.

By default, the SDK automatically flushes the data as soon as it is tracked or when the application is backgrounded. You can configure the [flushing mode](#flushing-modes) to customize this behavior to suit your needs.
 
 You can also turn off automatic flushing completely. In this case, you must [manually flush](#manual-flushing) every time there is data to flush.

The SDK will only flush data when the device has a stable network connection. If a connection error occurs while flushing, it will keep the data cached until the connection is stable and the data is flushed successfully.

## Flushing Modes

The SDK supports the following 4 flushing modes (defined in [`/lib/src/data/model/flush_mode.dart`](https://github.com/exponea/exponea-flutter-sdk/blob/main/lib/src/data/model/flush_mode.dart)) to specify how often or if data is flushed automatically.

| Name                            | Description |
| ------------------------------- | ----------- |
| `FlushMode.immediate` (default) | Flushes all data immediately as it is received. |
| `FlushMode.period`              | Flushes data in the interval specified using `setFlushPeriod(Duration)` and when the application is closed or goes to the background. |
| `FlushMode.appClose`            | Flush data any time the application resigns active state. |
| `FlushMode.manual`              | Disables any automatic upload. It's the responsibility of the developer to [flush data manually](#manual-flushing). |

To set the flushing mode, [initialize the SDK](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup) first, then call the `setFlushMode()` method with the desired mode as parameter:

```dart
ExponeaPlugin().setFlushMode(FlushMode.manual);
```

When using flush mode `FlushMode.period`, the default interval is 60 minutes. To specify a different interval, call the `setFlushPeriod()` method with a `Duration` value as parameter:

```dart
ExponeaPlugin().setFlushMode(FlushMode.period);
final period = Duration(minutes: 10);
ExponeaPlugin().setFlushPeriod(period);
```

## Manual Flushing

To manually trigger a data flush to the API, use the following method:

```dart
ExponeaPlugin().flushData();
```
