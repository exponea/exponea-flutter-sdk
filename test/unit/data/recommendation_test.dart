import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('Recommendation', () {
    const encode = RecommendationEncoder.encode;
    const decode = RecommendationEncoder.decode;

    final data = readMapData('recommendation');
    test('check data', () async {
      expect(data.length, 4);
    });
    final noData = data[0];
    final noItemIdData = data[1];
    final minData = data[2];
    final fullData = data[3];

    group('encode', () {
      test('min', () async {
        const recommendation = Recommendation(
          engineName: "mock-engine",
          itemId: "mock-item",
          recommendationId: "mock-rec-id",
          recommendationVariantId: "mock-variant-id",
          data: {},
        );
        expect(encode(recommendation), minData);
      });

      test('full', () async {
        const recommendation = Recommendation(
          engineName: "mock-engine",
          itemId: "mock-item",
          recommendationId: "mock-rec-id",
          recommendationVariantId: "mock-variant-id",
          data: {
            "integer": 123456,
            "decimal": 123.456,
            "boolean": true,
            "string": "example_string",
            "datetime": "2024-02-01T11:22:33.444Z"
          },
        );
        expect(encode(recommendation), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        try {
          decode(noData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'engineName is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('no fillWithRandom', () async {
        try {
          decode(noItemIdData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'itemId is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('min', () async {
        const expected = Recommendation(
          engineName: "mock-engine",
          itemId: "mock-item",
          recommendationId: "mock-rec-id",
          recommendationVariantId: "mock-variant-id",
          data: {},
        );
        final decoded = decode(minData);

        expect(decoded.engineName, expected.engineName);
        expect(decoded.itemId, expected.itemId);
        expect(decoded.recommendationId, expected.recommendationId);
        expect(decoded.recommendationVariantId, expected.recommendationVariantId);
        expect(decoded.data, expected.data);
      });

      test('full', () async {
        const expected = Recommendation(
          engineName: "mock-engine",
          itemId: "mock-item",
          recommendationId: "mock-rec-id",
          recommendationVariantId: "mock-variant-id",
          data: {
            "integer": 123456,
            "decimal": 123.456,
            "boolean": true,
            "string": "example_string",
            "datetime": "2024-02-01T11:22:33.444Z"
          },
        );
        final decoded = decode(fullData);

        expect(decoded.engineName, expected.engineName);
        expect(decoded.itemId, expected.itemId);
        expect(decoded.recommendationId, expected.recommendationId);
        expect(decoded.recommendationVariantId, expected.recommendationVariantId);
        expect(decoded.data, expected.data);
      });

      test('data type normalization', () async {
        // Test case for the inconsistent data types issue
        final testData = {
          "engineName": "test-engine",
          "itemId": "test-item",
          "recommendationId": "test-rec-id",
          "recommendationVariantId": "test-variant-id",
          "data": '{"sku_id": 60583300, "product_code": "60583300", "available": 101, "product_id": "05154586", "price": 6.9, "title": "Soft Lemon Scented Candle"}'
        };

        final decoded = decode(testData);

        // Verify that sku_id is converted to string
        expect(decoded.data['sku_id'], isA<String>());
        expect(decoded.data['sku_id'], '60583300');

        // Verify that product_code is converted to string
        expect(decoded.data['product_code'], isA<String>());
        expect(decoded.data['product_code'], '60583300');

        // Verify that available is converted to string
        expect(decoded.data['available'], isA<String>());
        expect(decoded.data['available'], '101');

        // Verify that product_id remains a string
        expect(decoded.data['product_id'], isA<String>());
        expect(decoded.data['product_id'], '05154586');

        // Verify that other fields maintain their original types
        expect(decoded.data['price'], isA<double>());
        expect(decoded.data['price'], 6.9);
        expect(decoded.data['title'], isA<String>());
        expect(decoded.data['title'], 'Soft Lemon Scented Candle');
      });
    });
  });

  group('RecommendationOptions', () {
    const encode = RecommendationOptionsEncoder.encode;
    const decode = RecommendationOptionsEncoder.decode;

    final data = readMapData('recommendation_options');
    test('check data', () async {
      expect(data.length, 4);
    });
    final noData = data[0];
    final noFillWithRandomData = data[1];
    final minData = data[2];
    final fullData = data[3];

    group('encode', () {
      test('min', () async {
        const options = RecommendationOptions(
          id: 'mock-id',
          fillWithRandom: true,
        );
        expect(encode(options), minData);
      });

      test('full', () async {
        const options = RecommendationOptions(
          id: 'mock-id',
          fillWithRandom: false,
          size: 5,
          items: {'a': 'b', 'c': 'd'},
          noTrack: true,
          catalogAttributesWhitelist: ['1', 'test', '...mock'],
        );
        expect(encode(options), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        try {
          decode(noData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'id is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('no fillWithRandom', () async {
        try {
          decode(noFillWithRandomData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'fillWithRandom is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('min', () async {
        const expected = RecommendationOptions(
          id: 'mock-id',
          fillWithRandom: true,
        );
        final decoded = decode(minData);

        expect(decoded.id, expected.id);
        expect(decoded.fillWithRandom, expected.fillWithRandom);
        expect(decoded.size, expected.size);
        expect(decoded.items, expected.items);
        expect(decoded.noTrack, expected.noTrack);
        expect(decoded.catalogAttributesWhitelist,
            expected.catalogAttributesWhitelist);
      });

      test('full', () async {
        const expected = RecommendationOptions(
          id: 'mock-id',
          fillWithRandom: false,
          size: 5,
          items: {'a': 'b', 'c': 'd'},
          noTrack: true,
          catalogAttributesWhitelist: ['1', 'test', '...mock'],
        );
        final decoded = decode(fullData);

        expect(decoded.id, expected.id);
        expect(decoded.fillWithRandom, expected.fillWithRandom);
        expect(decoded.size, expected.size);
        expect(decoded.items, expected.items);
        expect(decoded.noTrack, expected.noTrack);
        expect(decoded.catalogAttributesWhitelist,
            expected.catalogAttributesWhitelist);
      });
    });
  });
}
