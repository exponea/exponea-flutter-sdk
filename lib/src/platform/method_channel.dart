import 'dart:convert';

import 'package:exponea/exponea.dart';
import 'package:flutter/services.dart';

import '../data/encoder/main.dart';
import '../data/util/object.dart';

/// An implementation of [ExponeaPlatform] that uses method channels.
class MethodChannelExponeaPlatform extends ExponeaPlatform {
  static const _channelName = 'com.exponea';
  static const _channel = MethodChannel(_channelName);

  static const _openedPushStreamName = "$_channelName/opened_push";
  static const _openedPushEventChannel = EventChannel(_openedPushStreamName);

  static const _receivedPushStreamName = "$_channelName/received_push";
  static const _receivedPushEventChannel = EventChannel(_receivedPushStreamName);

  static const _inAppMessageActionStreamName = '$_channelName/in_app_messages';
  static const _inAppMessageActionEventChannel = EventChannel(_inAppMessageActionStreamName);

  static const _methodConfigure = 'configure';
  static const _methodIsConfigured = 'isConfigured';
  static const _methodGetCustomerCookie = 'getCustomerCookie';
  static const _methodIdentifyCustomer = 'identifyCustomer';
  static const _methodAnonymize = 'anonymize';
  static const _methodGetDefaultProperties = 'getDefaultProperties';
  static const _methodSetDefaultProperties = 'setDefaultProperties';
  static const _methodFlush = 'flush';
  static const _methodGetFlushMode = 'getFlushMode';
  static const _methodSetFlushMode = 'setFlushMode';
  static const _methodGetFlushPeriod = 'getFlushPeriod';
  static const _methodSetFlushPeriod = 'setFlushPeriod';
  static const _methodTrackEvent = 'trackEvent';
  static const _methodTrackSessionStart = 'trackSessionStart';
  static const _methodTrackSessionEnd = 'trackSessionEnd';
  static const _methodFetchConsents = 'fetchConsents';
  static const _methodFetchRecommendations = 'fetchRecommendations';
  static const _methodGetLogLevel = 'getLogLevel';
  static const _methodSetLogLevel = 'setLogLevel';
  static const _methodCheckPushSetup = 'checkPushSetup';
  static const _methodRequestPushAuthorization = 'requestPushAuthorization';
  static const _setAppInboxProvider = 'setAppInboxProvider';
  static const _trackAppInboxOpened = 'trackAppInboxOpened';
  static const _trackAppInboxOpenedWithoutTrackingConsent = 'trackAppInboxOpenedWithoutTrackingConsent';
  static const _trackAppInboxClick = 'trackAppInboxClick';
  static const _trackAppInboxClickWithoutTrackingConsent = 'trackAppInboxClickWithoutTrackingConsent';
  static const _markAppInboxAsRead = 'markAppInboxAsRead';
  static const _fetchAppInbox = 'fetchAppInbox';
  static const _fetchAppInboxItem = 'fetchAppInboxItem';
  static const _setInAppMessageActionHandler = 'setInAppMessageActionHandler';
  static const _trackInAppContentBlockClick = 'trackInAppContentBlockClick';
  static const _trackInAppContentBlockClickWithoutTrackingConsent = 'trackInAppContentBlockClickWithoutTrackingConsent';
  static const _trackInAppContentBlockClose = 'trackInAppContentBlockClose';
  static const _trackInAppContentBlockCloseWithoutTrackingConsent = 'trackInAppContentBlockCloseWithoutTrackingConsent';
  static const _trackInAppContentBlockShown = 'trackInAppContentBlockShown';
  static const _trackInAppContentBlockShownWithoutTrackingConsent = 'trackInAppContentBlockShownWithoutTrackingConsent';
  static const _trackInAppContentBlockError = 'trackInAppContentBlockError';
  static const _trackInAppContentBlockErrorWithoutTrackingConsent = 'trackInAppContentBlockErrorWithoutTrackingConsent';
  static const _trackInAppMessageClick = 'trackInAppMessageClick';
  static const _trackInAppMessageClickWithoutTrackingConsent = 'trackInAppMessageClickWithoutTrackingConsent';
  static const _trackInAppMessageClose = 'trackInAppMessageClose';
  static const _trackInAppMessageCloseWithoutTrackingConsent = 'trackInAppMessageCloseWithoutTrackingConsent';
  static const _trackPaymentEvent = 'trackPaymentEvent';
  static const _trackPushToken = 'trackPushToken';
  static const _trackHmsPushToken = 'trackHmsPushToken';
  static const _handlePushToken = 'handlePushToken';
  static const _handleHmsPushToken = 'handleHmsPushToken';
  static const _trackClickedPush = 'trackClickedPush';
  static const _trackClickedPushWithoutTrackingConsent = 'trackClickedPushWithoutTrackingConsent';
  static const _trackDeliveredPush = 'trackDeliveredPush';
  static const _trackDeliveredPushWithoutTrackingConsent = 'trackDeliveredPushWithoutTrackingConsent';
  static const _isBloomreachNotification = 'isBloomreachNotification';
  static const _handleCampaignClick = 'handleCampaignClick';
  static const _handlePushNotificationOpened = 'handlePushNotificationOpened';
  static const _handlePushNotificationOpenedWithoutTrackingConsent = 'handlePushNotificationOpenedWithoutTrackingConsent';

  Stream<OpenedPush>? _openedPushStream;
  Stream<ReceivedPush>? _receivedPushStream;
  Stream<InAppMessageAction>? _inAppMessageActionStream;

  @override
  Future<bool> configure(ExponeaConfiguration configuration) async {
    final data = ExponeaConfigurationEncoder.encode(configuration);
    return (await _channel.invokeMethod(_methodConfigure, data))!;
  }

  @override
  Future<bool> isConfigured() async {
    return (await _channel.invokeMethod<bool>(_methodIsConfigured))!;
  }

  @override
  Future<String> getCustomerCookie() async {
    return (await _channel.invokeMethod<String>(_methodGetCustomerCookie))!;
  }

  @override
  Future<void> identifyCustomer(Customer customer) async {
    final data = CustomerEncoder.encode(customer);
    await _channel.invokeMethod<void>(_methodIdentifyCustomer, data);
  }

  @override
  Future<void> anonymize([
    ExponeaConfigurationChange configChange =
        const ExponeaConfigurationChange(),
  ]) async {
    final data = ExponeaConfigurationChangeEncoder.encode(configChange);
    await _channel.invokeMethod<void>(_methodAnonymize, data);
  }

  @override
  Future<Map<String, dynamic>> getDefaultProperties() async {
    return (await _channel
        .invokeMapMethod<String, dynamic>(_methodGetDefaultProperties))!;
  }

  @override
  Future<void> setDefaultProperties(Map<String, dynamic> properties) async {
    await _channel.invokeMethod<void>(_methodSetDefaultProperties, properties);
  }

  @override
  Future<void> flushData() async {
    await _channel.invokeMethod<void>(_methodFlush);
  }

  @override
  Future<FlushMode> getFlushMode() async {
    final data = (await _channel.invokeMethod<String>(_methodGetFlushMode))!;
    return FlushModeEncoder.decode(data);
  }

  @override
  Future<void> setFlushMode(FlushMode mode) async {
    final data = FlushModeEncoder.encode(mode);
    await _channel.invokeMethod<void>(_methodSetFlushMode, data);
  }

  @override
  Future<Duration> getFlushPeriod() async {
    final data = (await _channel.invokeMethod<int>(_methodGetFlushPeriod))!;
    return DurationEncoder.decode(data);
  }

  @override
  Future<void> setFlushPeriod(Duration period) async {
    final data = DurationEncoder.encode(period);
    await _channel.invokeMethod<void>(_methodSetFlushPeriod, data);
  }

  @override
  Future<void> trackEvent(Event event) async {
    final data = EventEncoder.encode(event);
    await _channel.invokeMethod<void>(_methodTrackEvent, data);
  }

  @override
  Future<void> trackSessionStart({DateTime? timestamp}) async {
    final data = timestamp?.let(DateTimeEncoder.encode);
    await _channel.invokeMethod<void>(_methodTrackSessionStart, data);
  }

  @override
  Future<void> trackSessionEnd({DateTime? timestamp}) async {
    final data = timestamp?.let(DateTimeEncoder.encode);
    await _channel.invokeMethod<void>(_methodTrackSessionEnd, data);
  }

  @override
  Future<List<Consent>> fetchConsents() async {
    final outData =
        (await _channel.invokeListMethod<Map>(_methodFetchConsents))!;
    final res =
        outData.map((it) => ConsentEncoder.decode(it)).toList(growable: false);
    return res;
  }

  @override
  Future<List<Recommendation>> fetchRecommendations(
    RecommendationOptions options,
  ) async {
    const method = _methodFetchRecommendations;
    final inData = RecommendationOptionsEncoder.encode(options);
    final outData = (await _channel.invokeListMethod<Map>(method, inData))!;
    final res = outData
        .map((it) => RecommendationEncoder.decode(it))
        .toList(growable: false);
    return res;
  }

  @override
  Stream<OpenedPush> get openedPushStream {
    _openedPushStream ??= _openedPushEventChannel
        .receiveBroadcastStream()
        .cast<Map<dynamic, dynamic>>()
        .map((event) => OpenedPushEncoder.decode(event));
    return _openedPushStream!;
  }

  @override
  Stream<ReceivedPush> get receivedPushStream {
    _receivedPushStream ??= _receivedPushEventChannel
        .receiveBroadcastStream()
        .cast<Map<dynamic, dynamic>>()
        .map((event) => ReceivedPushEncoder.decode(event));
    return _receivedPushStream!;
  }

  @override
  Stream<InAppMessageAction> inAppMessageActionStream({bool overrideDefaultBehavior = false, bool trackActions = true}) {
    _channel.invokeMethod<void>(
      _setInAppMessageActionHandler,
      {
        'overrideDefaultBehavior': overrideDefaultBehavior,
        'trackActions': trackActions,
      },
    );
    _inAppMessageActionStream ??= _inAppMessageActionEventChannel
        .receiveBroadcastStream()
        .cast<Map<dynamic, dynamic>>()
        .map((event) => InAppMessageActionEncoder.decode(event));
    return _inAppMessageActionStream!;
  }

  @override
  Future<void> checkPushSetup() async {
    await _channel.invokeMethod<void>(_methodCheckPushSetup);
  }

  @override
  Future<bool> requestPushAuthorization() async {
    return (await _channel
        .invokeMethod<bool>(_methodRequestPushAuthorization))!;
  }

  @override
  Future<bool> requestIosPushAuthorization() async {
    return (await _channel
        .invokeMethod<bool>(_methodRequestPushAuthorization))!;
  }

  @override
  Future<LogLevel> getLogLevel() async {
    final data = (await _channel.invokeMethod<String>(_methodGetLogLevel))!;
    return LogLevelEncoder.decode(data);
  }

  @override
  Future<void> setLogLevel(LogLevel level) async {
    final data = LogLevelEncoder.encode(level);
    await _channel.invokeMethod<void>(_methodSetLogLevel, data);
  }

  @override
  Future<void> setAppInboxProvider(AppInboxStyle style) async {
    final data = style.encodeClean();
    await _channel.invokeMethod<void>(_setAppInboxProvider, data);
  }

  @override
  Future<void> trackAppInboxOpened(AppInboxMessage message) async {
    final data = AppInboxCoder.encodeMessage(message);
    await _channel.invokeMethod<void>(_trackAppInboxOpened, data);
  }

  @override
  Future<void> trackAppInboxOpenedWithoutTrackingConsent(AppInboxMessage message) async {
    final data = AppInboxCoder.encodeMessage(message);
    await _channel.invokeMethod<void>(_trackAppInboxOpenedWithoutTrackingConsent, data);
  }

  @override
  Future<void> trackAppInboxClick(AppInboxAction action, AppInboxMessage message) async {
    final data = AppInboxCoder.encodeActionMessage(action, message);
    await _channel.invokeMethod<void>(_trackAppInboxClick, data);
  }

  @override
  Future<void> trackAppInboxClickWithoutTrackingConsent(AppInboxAction action, AppInboxMessage message) async {
    final data = AppInboxCoder.encodeActionMessage(action, message);
    await _channel.invokeMethod<void>(_trackAppInboxClickWithoutTrackingConsent, data);
  }

  @override
  Future<bool> markAppInboxAsRead(AppInboxMessage message) async {
    final data = AppInboxCoder.encodeMessage(message);
    return (await _channel.invokeMethod<bool>(_markAppInboxAsRead, data))!;
  }

  @override
  Future<List<AppInboxMessage>> fetchAppInbox() async {
    final outData =
    (await _channel.invokeListMethod<Map>(_fetchAppInbox))!;
    final res =
    outData.map((it) => AppInboxCoder.decodeMessage(it)).toList(growable: false);
    return res;
  }

  @override
  Future<AppInboxMessage> fetchAppInboxItem(String messageId) async {
    const method = _fetchAppInboxItem;
    final inData = messageId;
    final outData = (await _channel.invokeMapMethod<String, dynamic>(method, inData))!;
    return AppInboxCoder.decodeMessage(outData);
  }

  @override
  Future<void> trackInAppContentBlockClick(String placeholderId, InAppContentBlock contentBlock, InAppContentBlockAction action) async {
    final contentBlockData = InAppContentBlockEncoder.encode(contentBlock);
    final data = {
      'placeholderId': placeholderId,
      'contentBlock': jsonEncode(contentBlockData),
      'action': InAppContentBlockActionEncoder.encode(action)
    };
    await _channel.invokeMethod<void>(_trackInAppContentBlockClick, data);
  }

  @override
  Future<void> trackInAppContentBlockClickWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock, InAppContentBlockAction action) async {
    final contentBlockData = InAppContentBlockEncoder.encode(contentBlock);
    final data = {
      'placeholderId': placeholderId,
      'contentBlock': jsonEncode(contentBlockData),
      'action': InAppContentBlockActionEncoder.encode(action)
    };
    await _channel.invokeMethod<void>(_trackInAppContentBlockClickWithoutTrackingConsent, data);
  }

  @override
  Future<void> trackInAppContentBlockClose(String placeholderId, InAppContentBlock contentBlock) async {
    final contentBlockData = InAppContentBlockEncoder.encode(contentBlock);
    final data = {
      'placeholderId': placeholderId,
      'contentBlock': jsonEncode(contentBlockData),
    };
    await _channel.invokeMethod<void>(_trackInAppContentBlockClose, data);
  }

  @override
  Future<void> trackInAppContentBlockCloseWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock) async {
    final contentBlockData = InAppContentBlockEncoder.encode(contentBlock);
    final data = {
      'placeholderId': placeholderId,
      'contentBlock': jsonEncode(contentBlockData),
    };
    await _channel.invokeMethod<void>(_trackInAppContentBlockCloseWithoutTrackingConsent, data);
  }

  @override
  Future<void> trackInAppContentBlockShown(String placeholderId, InAppContentBlock contentBlock) async {
    final contentBlockData = InAppContentBlockEncoder.encode(contentBlock);
    final data = {
      'placeholderId': placeholderId,
      'contentBlock': jsonEncode(contentBlockData),
    };
    await _channel.invokeMethod<void>(_trackInAppContentBlockShown, data);
  }

  @override
  Future<void> trackInAppContentBlockShownWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock) async {
    final contentBlockData = InAppContentBlockEncoder.encode(contentBlock);
    final data = {
      'placeholderId': placeholderId,
      'contentBlock': jsonEncode(contentBlockData),
    };
    await _channel.invokeMethod<void>(_trackInAppContentBlockShownWithoutTrackingConsent, data);
  }

  @override
  Future<void> trackInAppContentBlockError(String placeholderId, InAppContentBlock contentBlock, String errorMessage) async {
    final contentBlockData = InAppContentBlockEncoder.encode(contentBlock);
    final data = {
      'placeholderId': placeholderId,
      'contentBlock': jsonEncode(contentBlockData),
      'errorMessage': errorMessage,
    };
    await _channel.invokeMethod<void>(_trackInAppContentBlockError, data);
  }

  @override
  Future<void> trackInAppContentBlockErrorWithoutTrackingConsent(String placeholderId, InAppContentBlock contentBlock, String errorMessage) async {
    final contentBlockData = InAppContentBlockEncoder.encode(contentBlock);
    final data = {
      'placeholderId': placeholderId,
      'contentBlock': jsonEncode(contentBlockData),
      'errorMessage': errorMessage,
    };
    await _channel.invokeMethod<void>(_trackInAppContentBlockErrorWithoutTrackingConsent, data);
  }

  @override
  Future<void> trackInAppMessageClick(InAppMessage message, InAppMessageButton button) async {
    final data = {
      'message': InAppMessageEncoder.encode(message),
      'button': InAppMessageButtonEncoder.encode(button),
    };
    await _channel.invokeMethod<void>(_trackInAppMessageClick, data);
  }

  @override
  Future<void> trackInAppMessageClickWithoutTrackingConsent(InAppMessage message, InAppMessageButton button) async {
    final data = {
      'message': InAppMessageEncoder.encode(message),
      'button': InAppMessageButtonEncoder.encode(button),
    };
    await _channel.invokeMethod<void>(_trackInAppMessageClickWithoutTrackingConsent, data);
  }

  @override
  Future<void> trackInAppMessageClose(InAppMessage message, {InAppMessageButton? button, bool interaction = true}) async {
    final data = {
      'message': InAppMessageEncoder.encode(message),
      'button': button?.let(InAppMessageButtonEncoder.encode),
      'interaction': interaction,
    };
    await _channel.invokeMethod<void>(_trackInAppMessageClose, data);
  }

  @override
  Future<void> trackInAppMessageCloseWithoutTrackingConsent(InAppMessage message, {InAppMessageButton? button, bool interaction = true}) async {
    final data = {
      'message': InAppMessageEncoder.encode(message),
      'button': button?.let(InAppMessageButtonEncoder.encode),
      'interaction': interaction,
    };
    await _channel.invokeMethod<void>(_trackInAppMessageCloseWithoutTrackingConsent, data);
  }

  @override
  Future<void> trackPaymentEvent(PurchasedItem purchasedItem, {DateTime? timestamp}) async {
    final data = {
      'purchasedItem': PurchasedItemEncoder.encode(purchasedItem),
      'timestamp': timestamp?.let(DateTimeEncoder.encode),
    };
    await _channel.invokeMethod<void>(_trackPaymentEvent, data);
  }

  @override
  Future<void> trackPushToken(String token) async {
    await _channel.invokeMethod<void>(_trackPushToken, token);
  }

  @override
  Future<void> trackHmsPushToken(String token) async {
    await _channel.invokeMethod<void>(_trackHmsPushToken, token);
  }

  @override
  Future<void> handlePushToken(String token) async {
    await _channel.invokeMethod<void>(_handlePushToken, token);
  }

  @override
  Future<void> handleHmsPushToken(String token) async {
    await _channel.invokeMethod<void>(_handleHmsPushToken, token);
  }

  @override
  Future<void> trackClickedPush(Map<String, dynamic> data) async {
    await _channel.invokeMethod<void>(_trackClickedPush, data);
  }

  @override
  Future<void> trackClickedPushWithoutTrackingConsent(Map<String, dynamic> data) async {
    await _channel.invokeMethod<void>(_trackClickedPushWithoutTrackingConsent, data);
  }

  @override
  Future<void> trackDeliveredPush(Map<String, dynamic> data) async {
    await _channel.invokeMethod<void>(_trackDeliveredPush, data);
  }

  @override
  Future<void> trackDeliveredPushWithoutTrackingConsent(Map<String, dynamic> data) async {
    await _channel.invokeMethod<void>(_trackDeliveredPushWithoutTrackingConsent, data);
  }

  @override
  Future<bool> isBloomreachNotification(Map<String, String> data) async {
    return (await _channel.invokeMethod<bool>(_isBloomreachNotification, data))!;
  }

  @override
  Future<void> handleCampaignClick(String url) async {
    await _channel.invokeMethod<void>(_handleCampaignClick, url);
  }

  @override
  Future<void> handlePushNotificationOpened(Map<String, dynamic> data) async {
    await _channel.invokeMethod<void>(_handlePushNotificationOpened, data);
  }

  @override
  Future<void> handlePushNotificationOpenedWithoutTrackingConsent(Map<String, dynamic> data) async {
    await _channel.invokeMethod<void>(_handlePushNotificationOpenedWithoutTrackingConsent, data);
  }
}