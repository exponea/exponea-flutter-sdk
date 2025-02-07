---
title: Segmentation
excerpt: Implement real-time segments using the Flutter SDK
slug: flutter-sdk-segmentation
categorySlug: integrations
parentDocSlug: flutter-sdk
---

The [Real-time segments](https://documentation.bloomreach.com/discovery/docs/real-time-customer-segments-for-discovery) feature personalizes the product search, category and pathway results in real-time based on customer demographic and behavioral data. The feature combines Bloomreach Discovery’s extensive search algorithms and Bloomreach Engagement’s rich customer data to get the best of both worlds.

Refer to the [Discovery real-time segments](https://documentation.bloomreach.com/discovery/docs/real-time-customer-segments-for-discovery) documentation for more details about this feature.

This page describes the integration steps required to retrieve any segmentation data changes assigned to the current customer.

### Use real-time segments

To use real-time segments in your app, you must listen to one or more customized stream instances. to get these streams, you need to call `ExponeaPlugin().segmentationDataStream` method. This methods takes two arguments:

1. An `exposingCategory` indicating your point of interest for segmentation:
    * Possible values are `content`, `discovery`, or `merchandising`. You will get updates only for segmentation data assigned to the specified `exposingCategory`.
2. A boolean flag `includeFirstLoad` to force a fetch of segmentation data:
    * Setting this flag to `true` triggers a segmentation data fetch immediately.
    * The SDK will broadcast to this stream instance with the new data even if the data has not changed from the last known state.
    * If the data has changed, the SDK will also notify any other registered stream.
    * Setting this flag to `false` also triggers a segmentation data fetch, but the SDK only notifies the instance if the new data differs from the last known state.

#### Example

```dart
final _plugin = ExponeaPlugin();

 // get a segmentation data stream
final stream = await _plugin.segmentationDataStream('discovery', includeFirstLoad: true);

// Listen to the stream for segmentation data updates
stream.listen((segments) {
  print('Segments: Got new segments: $segments');
});
```

The data payload of each `Segment` is as follows:

```json
{ 
  "id": "66140257f4cb337324209871",
  "segmentation_id": "66140215fb50effc8a7218b4"
}
```

### Get segmentation data directly

The SDK provides an API to get segmentation data directly. Invoke the `ExponeaPlugin().getSegments` method, passing a `exposingCategory` value as argument:

```dart
final segments = await _plugin.getSegments('discovery');
print('Segments: Got new segments: $segments');
```

Segments data received by `getSegments` method are primary loaded from valid cache. Cache is automatically fetched from server if:

* cache is empty or was loaded for previous customer
* cache data are older than 5 seconds
* method is forced to fetch segments from server by developer

If you want to force to fetch segmentations data from server, use `force` parameter with `true` value as argument:

```dart
final segments = await _plugin.getSegments('discovery', force: true);
console.info('Segments: Got new segments: ' + segments);
```

### Segmentation data reload triggers

There are a few cases when the SDK refreshes segmentation data, and this process could occur multiple times. However, the SDK only notifies registered streams if the data have changed or if `includeFirstLoad` is `true`. Refer to [Stream behavior](#stream-behavior) for more details about the stream notification process.

A data reload is triggered in the following cases:

1. When a stream is registered while the SDK is fully initialized.
2. During SDK initialization if there is any stream registered.
3. When `ExponeaPlugin().identifyCustomer` is called with a [hard ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#section-hard-id).
4. When any event is tracked successfully.

When a segmentation data reload is triggered, the process waits 5 seconds before starting, in order to ensure duplicate update requests especially for higher frequency of events tracking.

> ❗️
>
> It is required to [set the flush mode](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-data-flushing#flushing-modes) to `FlushMode.immediate` to get accurate results. The process of segment calculation needs all tracked events to be uploaded to server to calculate results effectively.

### Stream behavior

The SDK allows you to register multiple stream instances for multiple categories or for the same category. You may register a stream with the SDK anytime (before and after initialization). Stream instances remain active until the application terminates or until you close the stream.

The stream behavior follows the following principles:

* A stream receives data assigned only for the specified `exposingCategory`.
* A stream is always notified if data differs from the previous reload in the scope of the specified `exposingCategory`.
* A newly registered stream is also notified for unchanged data if `includeFirstLoad` is `true`, but only once. On subsequent updates, the stream is notified only if the data have changed.
* A closed stream stops listening for data changes.
* After closing stream, getting new stream is required to listen for new data for specified `exposingCategory`.

> 👍
>
> Consider keeping the number of streams within a reasonable value.

### Listen to multiple segmentation categories

Although a segmentation data stream allows listening to only one `exposingCategory`, you can register multiple streams for multiple categories.

```dart
Future<void> initializeSegmentationDataStreams() async {
  final Exponea _plugin = Exponea();
  StreamSubscription? _discoverySubscription;
  StreamSubscription? _merchandisingSubscription;
  StreamSubscription? _contentSubscription;

  final discoveryStream = await _plugin.segmentationDataStream('discovery', includeFirstLoad: true);
  final merchandisingStream = await _plugin.segmentationDataStream('merchandising', includeFirstLoad: false);
  final contentStream = await _plugin.segmentationDataStream('content', includeFirstLoad: false);

  _discoverySubscription = discoveryStream.listen((segments) {
    print('Discovery segments: $segments');
  });

  _merchandisingSubscription = merchandisingStream.listen((segments) {
    print('Merchandising segments: $segments');
  });

  _contentSubscription = contentStream.listen((segments) {
    print('Content segments: $segments');
  });

  // Remember to cancel the subscriptions when they are no longer needed
  // _discoverySubscription?.cancel();
  // _merchandisingSubscription?.cancel();
  // _contentSubscription?.cancel();
}
```

### Troubleshooting

> 👍 Enable Verbose Logging
>
> The SDK logs a lot of useful information related to segmentation data updates on the `INFO` level. You can [set the logger level](https://documentation.bloomreach.com/engagement/docs/flutter-sdk-setup#log-level) using `ExponeaPlugin().setLogLevel` before initializing the SDK. If you face unexpected behavior and `INFO` log messages are not sufficient, set the log level to `VERBOSE` to got more detailed information.

> 👍
>
> All log messages related to the segmentation process are prefixed with `Segments:` to make them easier to find. Bear in mind that some supporting processes (such as HTTP communication) are logging without this prefix.


The process of updating segmentation data may be canceled due to the current state of the SDK. Segmentation data are assigned to the current customer and the process is active only if there are any streams registered. The SDK logs information about all these validations.

#### Log messages

If you are not receiving segmentation data updates, you may see the following log messages:

- ```
  Segments: Skipping segments update process after tracked event due to no callback registered
  ```
  The SDK tracked an event successfully but there is no registered stream for segments. Please register at least one stream.
- ```
  Segments: Adding of callback triggers fetch for no callbacks registered
  ```
  The SDK starts an update of segmentation data after a stream registration but this stream is missing while processing. Please ensure that you don't close the stream prematurely.
- ```
  Segments: Skipping segments reload process for no callback
  ```
  The SDK is trying to reload segmentation data but there is no registered stream for segments. Please register at least one stream.
- ```
  Segments: Skipping initial segments update process for no callback
  ```
  The SDK initialization flow tries to reload segmentation data but there is no registered stream for segments. To check segmentation data on SDK initialization, please register at least one stream before SDK initialization.
- ```
  Segments: Skipping initial segments update process as is not required
  ```
  The SDK initialization flow detects that all registered streams have `includeFirstLoad` with `false` value. To check segmentation data on SDK initialization, please register at least one stream with `includeFirstLoad` with `true` value before SDK initialization.

If you are not receiving segmentation data while registering a customer, please check your usage of `ExponeaPlugin().identifyCustomer` or `ExponeaPlugin().anonymize`. You may face these logs:

- ```
  Segments: Segments change check has been cancelled meanwhile
  ```
  The segmentation data update process started but was subsequently canceled by an invocation of `ExponeaPlugin().anonymize`. If this is unwanted behavior, check your `ExponeaPlugin().anonymize` usage.
- ```
  Segments: Check process was canceled because customer has changed
  ```
  The segmentation data update process started for the current customer but the customer ID was subsequently changed by an invocation of `ExponeaPlugin().identifyCustomer` for another customer. If this is unwanted behaviour, check your `ExponeaPlugin().identifyCustomer` usage.
- ```
  Segments: Customer IDs <customer_ids> merge failed, unable to fetch segments
  ```
  The segmentation data update process requires to link IDs but that part of the process failed. Please refer to the error log messages and check your `ExponeaPlugin().identifyCustomer` usage. This  should not happen, please discuss this with the Bloomreach support team.
- ```
  Segments: New data are ignored because were loaded for different customer
  ```
  The segmentation data update process detects that data has been fetched for a previous customer. This should not lead to any problem as there is another fetch process registered for the new customer, but you may face a short delay for new data retrieval. If you see this log often, check your `ExponeaPlugin().shared.identifyCustomer` usage.
- ```
  Segments: Fetch of segments failed: <error message>
  ```
  Please read the error message carefully. This message is logged if the data retrieval failed for some technical reason, such as an unstable network connection.