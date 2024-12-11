import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:exponea/src/data/model/in_app_message_action_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('InAppMessageAction', () {
    const encode = InAppMessageActionEncoder.encode;
    const decode = InAppMessageActionEncoder.decode;

    final data = readMapData('in_app_message_action');
    test('check data', () async {
      expect(data.length, 6);
    });
    final noData = data[0];
    final minData = data[1];
    final withMessage = data[2];
    final withInteraction = data[3];
    final withButton = data[4];
    final fullData = data[5];

    group('encode', () {
      test('minimal', () async {
        const inAppMessageAction = InAppMessageAction(
          type: InAppMessageActionType.show,
        );
        expect(encode(inAppMessageAction), minData);
      });

      test('with message value', () async {
        const inAppMessageAction = InAppMessageAction(
          type: InAppMessageActionType.show,
          message: InAppMessage(
            id: 'mock-id',
            name: 'mock-name',
            frequency: 'mock-frequency',
            variantId: 1,
            variantName: 'mock-variantName',
            messageType: 'mock-messageType',
            payload: {'mock-payload-param': 'mock-payload-content'},
            trigger: {'event_type': 'session_start', 'filter': []},
            dateFilter: {'mock-dateFilter-param': 'mock-dateFilter-content'},
            loadPriority: 1,
            loadDelay: 1000,
            closeTimeout: 2000,
            payloadHtml: 'mock-payloadHtml',
            isHtml: true,
            hasTrackingConsent: true,
            consentCategoryTracking: 'mock-consentCategoryTracking',
          ),
        );
        expect(encode(inAppMessageAction), withMessage);
      });

      test('with interaction value', () async {
        const inAppMessageAction = InAppMessageAction(
          type: InAppMessageActionType.show,
          message: InAppMessage(
            id: 'mock-id',
            name: 'mock-name',
            frequency: 'mock-frequency',
            variantId: 1,
            variantName: 'mock-variantName',
            messageType: 'mock-messageType',
            payload: {'mock-payload-param': 'mock-payload-content'},
            trigger: {'event_type': 'session_start', 'filter': []},
            dateFilter: {'mock-dateFilter-param': 'mock-dateFilter-content'},
            loadPriority: 1,
            loadDelay: 1000,
            closeTimeout: 2000,
            payloadHtml: 'mock-payloadHtml',
            isHtml: true,
            hasTrackingConsent: true,
            consentCategoryTracking: 'mock-consentCategoryTracking',
          ),
          interaction: true
        );
        expect(encode(inAppMessageAction), withInteraction);
      });

      test('with button value', () async {
        const inAppMessageAction = InAppMessageAction(
            type: InAppMessageActionType.show,
            message: InAppMessage(
              id: 'mock-id',
              name: 'mock-name',
              frequency: 'mock-frequency',
              variantId: 1,
              variantName: 'mock-variantName',
              messageType: 'mock-messageType',
              payload: {'mock-payload-param': 'mock-payload-content'},
              trigger: {'event_type': 'session_start', 'filter': []},
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
            )
        );
        expect(encode(inAppMessageAction), withButton);
      });

      test('full', () async {
        const inAppMessageAction = InAppMessageAction(
          type: InAppMessageActionType.show,
          message: InAppMessage(
            id: 'mock-id',
            name: 'mock-name',
            frequency: 'mock-frequency',
            variantId: 1,
            variantName: 'mock-variantName',
            messageType: 'mock-messageType',
            payload: {'mock-payload-param': 'mock-payload-content'},
            trigger: {'event_type': 'session_start', 'filter': []},
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
          ),
          errorMessage: "example error message",
        );
        expect(encode(inAppMessageAction), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        expect(() => decode(noData), throwsStateError);
      });

      test('minimal', () async {
        final decoded = decode(minData);
        expect(decoded.type, InAppMessageActionType.show);
        expect(decoded.message, null);
        expect(decoded.interaction, null);
        expect(decoded.button, null);
        expect(decoded.errorMessage, null);
      });

      test('with message value', () async {
        final decoded = decode(withMessage);
        expect(decoded.type, InAppMessageActionType.show);
        expect(decoded.message, isA<InAppMessage>());
        expect(decoded.interaction, null);
        expect(decoded.button, null);
        expect(decoded.errorMessage, null);
      });

      test('with interaction value', () async {
        final decoded = decode(withInteraction);
        expect(decoded.type, InAppMessageActionType.show);
        expect(decoded.message, isA<InAppMessage>());
        expect(decoded.interaction, true);
        expect(decoded.button, null);
        expect(decoded.errorMessage, null);
      });

      test('with button value', () async {
        final decoded = decode(withButton);
        expect(decoded.type, InAppMessageActionType.show);
        expect(decoded.message, isA<InAppMessage>());
        expect(decoded.interaction, true);
        expect(decoded.button, isA<InAppMessageButton>());
        expect(decoded.errorMessage, null);
      });

      test('full data', () async {
        final decoded = decode(fullData);
        expect(decoded.type, InAppMessageActionType.show);
        expect(decoded.message, isA<InAppMessage>());
        expect(decoded.interaction, true);
        expect(decoded.button, isA<InAppMessageButton>());
        expect(decoded.errorMessage, "example error message");
      });
    });
  });
}
