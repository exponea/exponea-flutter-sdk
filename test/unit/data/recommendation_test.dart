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
