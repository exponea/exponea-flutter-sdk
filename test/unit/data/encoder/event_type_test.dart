import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventTypeEncoder', () {
    final encode = EventTypeEncoder.encode;
    final decode = EventTypeEncoder.decode;

    test('encode', () async {
      expect(encode(EventType.install), 'INSTALL');
      expect(encode(EventType.sessionStart), 'SESSION_START');
      expect(encode(EventType.sessionEnd), 'SESSION_END');
      expect(encode(EventType.trackEvent), 'TRACK_EVENT');
      expect(encode(EventType.trackCustomer), 'TRACK_CUSTOMER');
      expect(encode(EventType.payment), 'PAYMENT');
      expect(encode(EventType.pushToken), 'PUSH_TOKEN');
      expect(encode(EventType.pushDelivered), 'PUSH_DELIVERED');
      expect(encode(EventType.pushOpened), 'PUSH_OPENED');
      expect(encode(EventType.campaignClick), 'CAMPAIGN_CLICK');
      expect(encode(EventType.banner), 'BANNER');
    });

    test('decode', () async {
      expect(decode('INSTALL'), EventType.install);
      expect(decode('SESSION_START'), EventType.sessionStart);
      expect(decode('SESSION_END'), EventType.sessionEnd);
      expect(decode('TRACK_EVENT'), EventType.trackEvent);
      expect(decode('TRACK_CUSTOMER'), EventType.trackCustomer);
      expect(decode('PAYMENT'), EventType.payment);
      expect(decode('PUSH_TOKEN'), EventType.pushToken);
      expect(decode('PUSH_DELIVERED'), EventType.pushDelivered);
      expect(decode('PUSH_OPENED'), EventType.pushOpened);
      expect(decode('CAMPAIGN_CLICK'), EventType.campaignClick);
      expect(decode('BANNER'), EventType.banner);
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
