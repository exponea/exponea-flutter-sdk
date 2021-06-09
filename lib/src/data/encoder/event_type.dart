import '../model/event_type.dart';

abstract class EventTypeEncoder {
  static String encode(EventType type) {
    switch (type) {
      case EventType.install:
        return 'INSTALL';
      case EventType.sessionStart:
        return 'SESSION_START';
      case EventType.sessionEnd:
        return 'SESSION_END';
      case EventType.trackEvent:
        return 'TRACK_EVENT';
      case EventType.trackCustomer:
        return 'TRACK_CUSTOMER';
      case EventType.payment:
        return 'PAYMENT';
      case EventType.pushToken:
        return 'PUSH_TOKEN';
      case EventType.pushDelivered:
        return 'PUSH_DELIVERED';
      case EventType.pushOpened:
        return 'PUSH_OPENED';
      case EventType.campaignClick:
        return 'CAMPAIGN_CLICK';
      case EventType.banner:
        return 'BANNER';
    }
  }

  static EventType decode(String value) {
    switch (value) {
      case 'INSTALL':
        return EventType.install;
      case 'SESSION_START':
        return EventType.sessionStart;
      case 'SESSION_END':
        return EventType.sessionEnd;
      case 'TRACK_EVENT':
        return EventType.trackEvent;
      case 'TRACK_CUSTOMER':
        return EventType.trackCustomer;
      case 'PAYMENT':
        return EventType.payment;
      case 'PUSH_TOKEN':
        return EventType.pushToken;
      case 'PUSH_DELIVERED':
        return EventType.pushDelivered;
      case 'PUSH_OPENED':
        return EventType.pushOpened;
      case 'CAMPAIGN_CLICK':
        return EventType.campaignClick;
      case 'BANNER':
        return EventType.banner;
      default:
        throw UnsupportedError('`$value` is not an EventType!');
    }
  }
}
