import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('InAppMessage', () {
    const encode = InAppMessageEncoder.encode;
    const decode = InAppMessageEncoder.decode;

    final data = readMapData('in_app_message');
    test('check data', () async {
      expect(data.length, 13);
    });
    final noData = data[0];
    final minData = data[1];
    final withMessageTypeData = data[2];
    final withPayloadData = data[3];
    final withTriggerData = data[4];
    final withDateFilterData = data[5];
    final withLoadPriorityData = data[6];
    final withLoadDelayData = data[7];
    final withCloseTimeoutData = data[8];
    final withPayloadHtmlData = data[9];
    final withIsHtmlData = data[10];
    final withHasTrackingConsentData = data[11];
    final fullData = data[12];

    group('encode', () {
      test('minimal', () async {
        const inAppMessage = InAppMessage(
          id: 'mock-id',
          name: 'mock-name',
          frequency: 'mock-frequency',
          variantId: 1,
          variantName: 'mock-variantName',
        );
        expect(encode(inAppMessage), minData);
      });

      test('with messageType value', () async {
        const inAppMessage = InAppMessage(
          id: 'mock-id',
          name: 'mock-name',
          frequency: 'mock-frequency',
          variantId: 1,
          variantName: 'mock-variantName',
          messageType: 'mock-messageType',
        );
        expect(encode(inAppMessage), withMessageTypeData);
      });

      test('with payload value', () async {
        const inAppMessage = InAppMessage(
          id: 'mock-id',
          name: 'mock-name',
          frequency: 'mock-frequency',
          variantId: 1,
          variantName: 'mock-variantName',
          messageType: 'mock-messageType',
          payload: {'mock-payload-param': 'mock-payload-content'},
        );
        expect(encode(inAppMessage), withPayloadData);
      });

      test('with trigger value', () async {
        const inAppMessage = InAppMessage(
          id: 'mock-id',
          name: 'mock-name',
          frequency: 'mock-frequency',
          variantId: 1,
          variantName: 'mock-variantName',
          messageType: 'mock-messageType',
          payload: {'mock-payload-param': 'mock-payload-content'},
          trigger: {'mock-trigger-param': 'mock-trigger-content'},
        );
        expect(encode(inAppMessage), withTriggerData);
      });

      test('with dateFilter value', () async {
        const inAppMessage = InAppMessage(
          id: 'mock-id',
          name: 'mock-name',
          frequency: 'mock-frequency',
          variantId: 1,
          variantName: 'mock-variantName',
          messageType: 'mock-messageType',
          payload: {'mock-payload-param': 'mock-payload-content'},
          trigger: {'mock-trigger-param': 'mock-trigger-content'},
          dateFilter: {'mock-dateFilter-param': 'mock-dateFilter-content'},
        );
        expect(encode(inAppMessage), withDateFilterData);
      });

      test('with loadPriority value', () async {
        const inAppMessage = InAppMessage(
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
        );
        expect(encode(inAppMessage), withLoadPriorityData);
      });

      test('with LoadDelay value', () async {
        const inAppMessage = InAppMessage(
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
        );
        expect(encode(inAppMessage), withLoadDelayData);
      });

      test('with closeTimeout value', () async {
        const inAppMessage = InAppMessage(
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
        );
        expect(encode(inAppMessage), withCloseTimeoutData);
      });

      test('with payloadHtml value', () async {
        const inAppMessage = InAppMessage(
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
        );
        expect(encode(inAppMessage), withPayloadHtmlData);
      });

      test('with isHtml value', () async {
        const inAppMessage = InAppMessage(
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
        );
        expect(encode(inAppMessage), withIsHtmlData);
      });

      test('with hasTrackingConsent value', () async {
        const inAppMessage = InAppMessage(
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
        );
        expect(encode(inAppMessage), withHasTrackingConsentData);
      });

      test('full data', () async {
        const inAppMessage = InAppMessage(
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
        );
        expect(encode(inAppMessage), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        expect(() => decode(noData), throwsStateError);
      });

      test('minimal', () async {
        final decoded = decode(minData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, null);
        expect(decoded.payload, null);
        expect(decoded.trigger, null);
        expect(decoded.dateFilter, null);
        expect(decoded.loadPriority, null);
        expect(decoded.loadDelay, null);
        expect(decoded.closeTimeout, null);
        expect(decoded.payloadHtml, null);
        expect(decoded.isHtml, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with messageType value', () async {
        final decoded = decode(withMessageTypeData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, null);
        expect(decoded.trigger, null);
        expect(decoded.dateFilter, null);
        expect(decoded.loadPriority, null);
        expect(decoded.loadDelay, null);
        expect(decoded.closeTimeout, null);
        expect(decoded.payloadHtml, null);
        expect(decoded.isHtml, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with payload value', () async {
        final decoded = decode(withPayloadData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, null);
        expect(decoded.dateFilter, null);
        expect(decoded.loadPriority, null);
        expect(decoded.loadDelay, null);
        expect(decoded.closeTimeout, null);
        expect(decoded.payloadHtml, null);
        expect(decoded.isHtml, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with trigger value', () async {
        final decoded = decode(withTriggerData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, {"mock-trigger-param": "mock-trigger-content"});
        expect(decoded.dateFilter, null);
        expect(decoded.loadPriority, null);
        expect(decoded.loadDelay, null);
        expect(decoded.closeTimeout, null);
        expect(decoded.payloadHtml, null);
        expect(decoded.isHtml, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with dateFilter value', () async {
        final decoded = decode(withDateFilterData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, {"mock-trigger-param": "mock-trigger-content"});
        expect(decoded.dateFilter, {"mock-dateFilter-param": "mock-dateFilter-content"});
        expect(decoded.loadPriority, null);
        expect(decoded.loadDelay, null);
        expect(decoded.closeTimeout, null);
        expect(decoded.payloadHtml, null);
        expect(decoded.isHtml, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with loadPriority value', () async {
        final decoded = decode(withLoadPriorityData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, {"mock-trigger-param": "mock-trigger-content"});
        expect(decoded.dateFilter, {"mock-dateFilter-param": "mock-dateFilter-content"});
        expect(decoded.loadPriority, 1);
        expect(decoded.loadDelay, null);
        expect(decoded.closeTimeout, null);
        expect(decoded.payloadHtml, null);
        expect(decoded.isHtml, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with loadDelay value', () async {
        final decoded = decode(withLoadDelayData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, {"mock-trigger-param": "mock-trigger-content"});
        expect(decoded.dateFilter, {"mock-dateFilter-param": "mock-dateFilter-content"});
        expect(decoded.loadPriority, 1);
        expect(decoded.loadDelay, 1000);
        expect(decoded.closeTimeout, null);
        expect(decoded.payloadHtml, null);
        expect(decoded.isHtml, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with closeTimeout value', () async {
        final decoded = decode(withCloseTimeoutData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, {"mock-trigger-param": "mock-trigger-content"});
        expect(decoded.dateFilter, {"mock-dateFilter-param": "mock-dateFilter-content"});
        expect(decoded.loadPriority, 1);
        expect(decoded.loadDelay, 1000);
        expect(decoded.closeTimeout, 2000);
        expect(decoded.payloadHtml, null);
        expect(decoded.isHtml, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with payloadHtml value', () async {
        final decoded = decode(withPayloadHtmlData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, {"mock-trigger-param": "mock-trigger-content"});
        expect(decoded.dateFilter, {"mock-dateFilter-param": "mock-dateFilter-content"});
        expect(decoded.loadPriority, 1);
        expect(decoded.loadDelay, 1000);
        expect(decoded.closeTimeout, 2000);
        expect(decoded.payloadHtml, 'mock-payloadHtml');
        expect(decoded.isHtml, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with isHtml value', () async {
        final decoded = decode(withIsHtmlData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, {"mock-trigger-param": "mock-trigger-content"});
        expect(decoded.dateFilter, {"mock-dateFilter-param": "mock-dateFilter-content"});
        expect(decoded.loadPriority, 1);
        expect(decoded.loadDelay, 1000);
        expect(decoded.closeTimeout, 2000);
        expect(decoded.payloadHtml, 'mock-payloadHtml');
        expect(decoded.isHtml, true);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.consentCategoryTracking, null);
      });

      test('with hasTrackingConsent value', () async {
        final decoded = decode(withHasTrackingConsentData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, {"mock-trigger-param": "mock-trigger-content"});
        expect(decoded.dateFilter, {"mock-dateFilter-param": "mock-dateFilter-content"});
        expect(decoded.loadPriority, 1);
        expect(decoded.loadDelay, 1000);
        expect(decoded.closeTimeout, 2000);
        expect(decoded.payloadHtml, 'mock-payloadHtml');
        expect(decoded.isHtml, true);
        expect(decoded.hasTrackingConsent, true);
        expect(decoded.consentCategoryTracking, null);
      });

      test('full data', () async {
        final decoded = decode(fullData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.variantId, 1);
        expect(decoded.variantName, 'mock-variantName');
        expect(decoded.messageType, 'mock-messageType');
        expect(decoded.payload, {"mock-payload-param": "mock-payload-content"});
        expect(decoded.trigger, {"mock-trigger-param": "mock-trigger-content"});
        expect(decoded.dateFilter, {"mock-dateFilter-param": "mock-dateFilter-content"});
        expect(decoded.loadPriority, 1);
        expect(decoded.loadDelay, 1000);
        expect(decoded.closeTimeout, 2000);
        expect(decoded.payloadHtml, 'mock-payloadHtml');
        expect(decoded.isHtml, true);
        expect(decoded.hasTrackingConsent, true);
        expect(decoded.consentCategoryTracking, 'mock-consentCategoryTracking');
      });
    });
  });
}
