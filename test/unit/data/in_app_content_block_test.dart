import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('InAppContentBlock', () {
    const encode = InAppContentBlockEncoder.encode;
    const decode = InAppContentBlockEncoder.decode;

    final data = readMapData('in_app_content_block');
    test('check data', () async {
      expect(data.length, 11);
    });

    final noData = data[0];
    final minData = data[1];
    final withDateFilter = data[2];
    final withFrequency = data[3];
    final withLoadPriority = data[4];
    final withConsentCategoryTracking = data[5];
    final withContentType = data[6];
    final withContent = data[7];
    final withPlaceholders = data[8];
    final withCustomerIds = data[9];
    final fullData = data[10];

    group('encode', () {
      test('no data', () async {
        expect(() => decode(noData), throwsStateError);
      });

      test('minimal', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          placeholders: [],
        );
        expect(encode(contentBlock), minData);
      });

      test('with dateFilter value', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          dateFilter: {'mock-date_filter-param': 'mock-date_filter-content'},
          placeholders: [],
        );
        expect(encode(contentBlock), withDateFilter);
      });

      test('with frequency value', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          dateFilter: {'mock-date_filter-param': 'mock-date_filter-content'},
          frequency: 'mock-frequency',
          placeholders: [],
        );
        expect(encode(contentBlock), withFrequency);
      });

      test('with loadPriority value', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          dateFilter: {'mock-date_filter-param': 'mock-date_filter-content'},
          frequency: 'mock-frequency',
          loadPriority: 1,
          placeholders: [],
        );
        expect(encode(contentBlock), withLoadPriority);
      });

      test('with consentCategoryTracking value', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          dateFilter: {'mock-date_filter-param': 'mock-date_filter-content'},
          frequency: 'mock-frequency',
          loadPriority: 1,
          consentCategoryTracking: 'mock-consent_category_tracking',
          placeholders: [],
        );
        expect(encode(contentBlock), withConsentCategoryTracking);
      });

      test('with contentType value', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          dateFilter: {'mock-date_filter-param': 'mock-date_filter-content'},
          frequency: 'mock-frequency',
          loadPriority: 1,
          consentCategoryTracking: 'mock-consent_category_tracking',
          contentType: 'mock-content_type',
          placeholders: [],
        );
        expect(encode(contentBlock), withContentType);
      });

      test('with content value', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          dateFilter: {'mock-date_filter-param': 'mock-date_filter-content'},
          frequency: 'mock-frequency',
          loadPriority: 1,
          consentCategoryTracking: 'mock-consent_category_tracking',
          contentType: 'mock-content_type',
          content: {'mock-content_param': 'mock-content_value'},
          placeholders: [],
        );
        expect(encode(contentBlock), withContent);
      });

      test('with placeholders value', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          dateFilter: {'mock-date_filter-param': 'mock-date_filter-content'},
          frequency: 'mock-frequency',
          loadPriority: 1,
          consentCategoryTracking: 'mock-consent_category_tracking',
          contentType: 'mock-content_type',
          content: {'mock-content_param': 'mock-content_value'},
          placeholders: ['placeholder1', 'placeholder2'],
        );
        expect(encode(contentBlock), withPlaceholders);
      });

      test('with customerIds', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          dateFilter: {'mock-date_filter-param': 'mock-date_filter-content'},
          frequency: 'mock-frequency',
          loadPriority: 1,
          consentCategoryTracking: 'mock-consent_category_tracking',
          contentType: 'mock-content_type',
          content: {'mock-content_param': 'mock-content_value'},
          placeholders: ['placeholder1', 'placeholder2'],
          customerIds: {'mock-customer_id-key': 'mock-customer_id-value'},
        );
        expect(encode(contentBlock), withCustomerIds);
      });

      test('full data', () async {
        const contentBlock = InAppContentBlock(
          id: 'mock-id',
          name: 'mock-name',
          dateFilter: {'mock-date_filter-param': 'mock-date_filter-content'},
          frequency: 'mock-frequency',
          loadPriority: 1,
          consentCategoryTracking: 'mock-consent_category_tracking',
          contentType: 'mock-content_type',
          content: {'mock-content_param': 'mock-content_value'},
          placeholders: ['placeholder1', 'placeholder2'],
          customerIds: {'mock-customer_id-key': 'mock-customer_id-value'},
          personalizedData: InAppContentBlockPersonalizedData(
            id: "mock-id",
            status: "mock-status",
            timeToLive: 3600,
            hasTrackingConsent: true,
            variantId: 123,
            variantName: "mock-variant",
            contentType: "mock-content-type",
            content: {
              "mock-key": "mock-value"
            },
            loadedAt: "mock-loaded-at",
          ),
        );
        expect(encode(contentBlock), fullData);
      });
    });

    group('decode', () {
      test('minimal', () async {
        final decoded = decode(minData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, null);
        expect(decoded.frequency, null);
        expect(decoded.loadPriority, null);
        expect(decoded.consentCategoryTracking, null);
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.placeholders, []);
      });

      test('with dateFilter value', () async {
        final decoded = decode(withDateFilter);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, {'mock-date_filter-param': 'mock-date_filter-content'});
        expect(decoded.frequency, null);
        expect(decoded.loadPriority, null);
        expect(decoded.consentCategoryTracking, null);
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.placeholders, []);
      });

      test('with frequency value', () async {
        final decoded = decode(withFrequency);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, {'mock-date_filter-param': 'mock-date_filter-content'});
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.loadPriority, null);
        expect(decoded.consentCategoryTracking, null);
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.placeholders, []);
      });

      test('with loadPriority value', () async {
        final decoded = decode(withLoadPriority);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, {'mock-date_filter-param': 'mock-date_filter-content'});
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.loadPriority, 1);
        expect(decoded.consentCategoryTracking, null);
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.placeholders, []);
      });

      test('with consentCategoryTracking value', () async {
        final decoded = decode(withConsentCategoryTracking);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, {'mock-date_filter-param': 'mock-date_filter-content'});
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.loadPriority, 1);
        expect(decoded.consentCategoryTracking, 'mock-consent_category_tracking');
        expect(decoded.contentType, null);
        expect(decoded.content, null);
        expect(decoded.placeholders, []);
      });

      test('with contentType value', () async {
        final decoded = decode(withContentType);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, {'mock-date_filter-param': 'mock-date_filter-content'});
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.loadPriority, 1);
        expect(decoded.consentCategoryTracking, 'mock-consent_category_tracking');
        expect(decoded.contentType, 'mock-content_type');
        expect(decoded.content, null);
        expect(decoded.placeholders, []);
      });

      test('with content value', () async {
        final decoded = decode(withContent);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, {'mock-date_filter-param': 'mock-date_filter-content'});
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.loadPriority, 1);
        expect(decoded.consentCategoryTracking, 'mock-consent_category_tracking');
        expect(decoded.contentType, 'mock-content_type');
        expect(decoded.content, {'mock-content_param': 'mock-content_value'});
        expect(decoded.placeholders, []);
      });

      test('with placeholders value', () async {
        final decoded = decode(withPlaceholders);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, {'mock-date_filter-param': 'mock-date_filter-content'});
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.loadPriority, 1);
        expect(decoded.consentCategoryTracking, 'mock-consent_category_tracking');
        expect(decoded.contentType, 'mock-content_type');
        expect(decoded.content, {'mock-content_param': 'mock-content_value'});
        expect(decoded.placeholders, ['placeholder1', 'placeholder2']);
      });

      test('with customerIds value', () async {
        final decoded = decode(withCustomerIds);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, {'mock-date_filter-param': 'mock-date_filter-content'});
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.loadPriority, 1);
        expect(decoded.consentCategoryTracking, 'mock-consent_category_tracking');
        expect(decoded.contentType, 'mock-content_type');
        expect(decoded.content, {'mock-content_param': 'mock-content_value'});
        expect(decoded.placeholders, ['placeholder1', 'placeholder2']);
        expect(decoded.customerIds, {'mock-customer_id-key': 'mock-customer_id-value'});
      });

      test('full data', () async {
        final decoded = decode(fullData);
        expect(decoded.id, 'mock-id');
        expect(decoded.name, 'mock-name');
        expect(decoded.dateFilter, {'mock-date_filter-param': 'mock-date_filter-content'});
        expect(decoded.frequency, 'mock-frequency');
        expect(decoded.loadPriority, 1);
        expect(decoded.consentCategoryTracking, 'mock-consent_category_tracking');
        expect(decoded.contentType, 'mock-content_type');
        expect(decoded.content, {'mock-content_param': 'mock-content_value'});
        expect(decoded.placeholders, ['placeholder1', 'placeholder2']);
        expect(decoded.customerIds, {'mock-customer_id-key': 'mock-customer_id-value'});
        expect(decoded.personalizedData, isA<InAppContentBlockPersonalizedData>());
      });
    });
  });
}