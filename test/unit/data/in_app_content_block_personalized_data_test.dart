import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('InAppContentBlockPersonalizedDataEncoder', () {
    const encode = InAppContentBlockPersonalizedDataEncoder.encode;
    const decode = InAppContentBlockPersonalizedDataEncoder.decode;

    final data = readMapData('in_app_content_block_personalized_data');
    test('check data', () async {
      expect(data.length, 10);
    });

    final noData = data[0];
    final minData = data[1];
    final withStatus = data[2];
    final withTimeToLive = data[3];
    final withTrackingConsent = data[4];
    final withVariantId = data[5];
    final withVariantName = data[6];
    final withContentType = data[7];
    final withContent = data[8];
    final fullData = data[9];

    group('encode', () {
      test('minimal', () async {
        const personalizedData = InAppContentBlockPersonalizedData(
          id: 'mock-id',
        );
        expect(encode(personalizedData), minData);
      });

      test('with status value', () async {
        const personalizedData = InAppContentBlockPersonalizedData(
          id: 'mock-id',
          status: 'mock-status',
        );
        expect(encode(personalizedData), withStatus);
      });

      test('with timeToLive value', () async {
        const personalizedData = InAppContentBlockPersonalizedData(
          id: 'mock-id',
          status: 'mock-status',
          timeToLive: 3600,
        );
        expect(encode(personalizedData), withTimeToLive);
      });

      test('with hasTrackingConsent value', () async {
        const personalizedData = InAppContentBlockPersonalizedData(
          id: 'mock-id',
          status: 'mock-status',
          timeToLive: 3600,
          hasTrackingConsent: true,
        );
        expect(encode(personalizedData), withTrackingConsent);
      });

      test('with variantId value', () async {
        const personalizedData = InAppContentBlockPersonalizedData(
          id: 'mock-id',
          status: 'mock-status',
          timeToLive: 3600,
          hasTrackingConsent: true,
          variantId: 123,
        );
        expect(encode(personalizedData), withVariantId);
      });

      test('with variantName value', () async {
        const personalizedData = InAppContentBlockPersonalizedData(
          id: 'mock-id',
          status: 'mock-status',
          timeToLive: 3600,
          hasTrackingConsent: true,
          variantId: 123,
          variantName: 'mock-variant',
        );
        expect(encode(personalizedData), withVariantName);
      });

      test('with contentType value', () async {
        const personalizedData = InAppContentBlockPersonalizedData(
          id: 'mock-id',
          status: 'mock-status',
          timeToLive: 3600,
          hasTrackingConsent: true,
          variantId: 123,
          variantName: 'mock-variant',
          contentType: 'mock-content-type',
        );
        expect(encode(personalizedData), withContentType);
      });

      test('with content value', () async {
        const personalizedData = InAppContentBlockPersonalizedData(
          id: 'mock-id',
          status: 'mock-status',
          timeToLive: 3600,
          hasTrackingConsent: true,
          variantId: 123,
          variantName: 'mock-variant',
          contentType: 'mock-content-type',
          content: {'mock-key': 'mock-value'},
        );
        expect(encode(personalizedData), withContent);
      });

      test('full data', () async {
        const personalizedData = InAppContentBlockPersonalizedData(
          id: 'mock-id',
          status: 'mock-status',
          timeToLive: 3600,
          hasTrackingConsent: true,
          variantId: 123,
          variantName: 'mock-variant',
          contentType: 'mock-content-type',
          content: {'mock-key': 'mock-value'},
          loadedAt: 'mock-loaded-at',
        );
        expect(encode(personalizedData), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        expect(() => decode(noData), throwsStateError);
      });

      test('minimal', () async {
        final decoded = decode(minData);
        expect(decoded.id, 'mock-id');
        expect(decoded.status, null);
        expect(decoded.timeToLive, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.variantId, null);
        expect(decoded.variantName, null);
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.loadedAt, null);
      });

      test('with status value', () async {
        final decoded = decode(withStatus);
        expect(decoded.id, 'mock-id');
        expect(decoded.status, 'mock-status');
        expect(decoded.timeToLive, null);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.variantId, null);
        expect(decoded.variantName, null);
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.loadedAt, null);
      });

      test('with timeToLive value', () async {
        final decoded = decode(withTimeToLive);
        expect(decoded.id, 'mock-id');
        expect(decoded.status, 'mock-status');
        expect(decoded.timeToLive, 3600);
        expect(decoded.hasTrackingConsent, null);
        expect(decoded.variantId, null);
        expect(decoded.variantName, null);
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.loadedAt, null);
      });

      test('with hasTrackingConsent value', () async {
        final decoded = decode(withTrackingConsent);
        expect(decoded.id, 'mock-id');
        expect(decoded.status, 'mock-status');
        expect(decoded.timeToLive, 3600);
        expect(decoded.hasTrackingConsent, true);
        expect(decoded.variantId, null);
        expect(decoded.variantName, null);
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.loadedAt, null);
      });

      test('with variantId value', () async {
        final decoded = decode(withVariantId);
        expect(decoded.id, 'mock-id');
        expect(decoded.status, 'mock-status');
        expect(decoded.timeToLive, 3600);
        expect(decoded.hasTrackingConsent, true);
        expect(decoded.variantId, 123);
        expect(decoded.variantName, null);
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.loadedAt, null);
      });

      test('with variantName value', () async {
        final decoded = decode(withVariantName);
        expect(decoded.id, 'mock-id');
        expect(decoded.status, 'mock-status');
        expect(decoded.timeToLive, 3600);
        expect(decoded.hasTrackingConsent, true);
        expect(decoded.variantId, 123);
        expect(decoded.variantName, 'mock-variant');
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.loadedAt, null);
      });

      test('with contentType value', () async {
        final decoded = decode(withContentType);
        expect(decoded.id, 'mock-id');
        expect(decoded.status, 'mock-status');
        expect(decoded.timeToLive, 3600);
        expect(decoded.hasTrackingConsent, true);
        expect(decoded.variantId, 123);
        expect(decoded.variantName, 'mock-variant');
        expect(decoded.contentType, 'mock-content-type');
        expect(decoded.content, null);
        expect(decoded.loadedAt, null);
      });

      test('with content value', () async {
        final decoded = decode(withContent);
        expect(decoded.id, 'mock-id');
        expect(decoded.status, 'mock-status');
        expect(decoded.timeToLive, 3600);
        expect(decoded.hasTrackingConsent, true);
        expect(decoded.variantId, 123);
        expect(decoded.variantName, 'mock-variant');
        expect(decoded.contentType, 'mock-content-type');
        expect(decoded.content, {'mock-key': 'mock-value'});
        expect(decoded.loadedAt, null);
      });

      test('full data', () async {
        final decoded = decode(fullData);
        expect(decoded.id, 'mock-id');
        expect(decoded.status, 'mock-status');
        expect(decoded.timeToLive, 3600);
        expect(decoded.hasTrackingConsent, true);
        expect(decoded.variantId, 123);
        expect(decoded.variantName, 'mock-variant');
        expect(decoded.contentType, 'mock-content-type');
        expect(decoded.content, {'mock-key': 'mock-value'});
        expect(decoded.loadedAt, 'mock-loaded-at');
      });
    });
  });
}