import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('InAppMessageAction', () {
    const encode = InAppMessageActionEncoder.encode;
    const decode = InAppMessageActionEncoder.decode;

    final data = readMapData('in_app_message_action');
    test('check data', () async {
      expect(data.length, 3);
    });
    final noData = data[0];
    final minData = data[1];
    final fullData = data[2];

    group('encode', () {
      test('minimal', () async {
        const inAppMessageAction = InAppMessageAction(
          message: InAppMessage(
            id: 'mock-id',
            name: 'mock-name',
            frequency: 'mock-frequency',
            variantId: 1,
            variantName: 'mock-variantName',
            messageType: 'mock-messageType',
            payload: {'mock-payload-param': 'mock-payload-content'},
            trigger: {'mock-trigger-param': 'mock-trigger-content'},
            dateFilter: {'mock-dateFilter-param': 'mock-dateFilter-content'},
            loadPriority: 1,
            loadDelay: 1000,
            closeTimeout: 2000,
            payloadHtml: 'mock-payloadHtml',
            isHtml: true,
            hasTrackingConsent: true,
            consentCategoryTracking: 'mock-consentCategoryTracking',
          ),
          interaction: true,
        );
        expect(encode(inAppMessageAction), minData);
      });

      test('full', () async {
        const inAppMessageAction = InAppMessageAction(
            message: InAppMessage(
              id: 'mock-id',
              name: 'mock-name',
              frequency: 'mock-frequency',
              variantId: 1,
              variantName: 'mock-variantName',
              messageType: 'mock-messageType',
              payload: {'mock-payload-param': 'mock-payload-content'},
              trigger: {'mock-trigger-param': 'mock-trigger-content'},
              dateFilter: {'mock-dateFilter-param': 'mock-dateFilter-content'},
              loadPriority: 1,
              loadDelay: 1000,
              closeTimeout: 2000,
              payloadHtml: 'mock-payloadHtml',
              isHtml: true,
              hasTrackingConsent: true,
              consentCategoryTracking: 'mock-consentCategoryTracking',
            ),
            interaction: true,
            button: InAppMessageButton(
              text: 'button',
              url: "https://a.b.c",
            ));
        expect(encode(inAppMessageAction), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        expect(() => decode(noData), throwsStateError);
      });

      test('minimal', () async {
        final decoded = decode(minData);
        expect(decoded.message, isA<InAppMessage>());
        expect(decoded.interaction, true);
        expect(decoded.button, null);
      });

      test('full data', () async {
        final decoded = decode(fullData);
        expect(decoded.message, isA<InAppMessage>());
        expect(decoded.interaction, true);
        expect(decoded.button, isA<InAppMessageButton>());
      });
    });
  });
}
