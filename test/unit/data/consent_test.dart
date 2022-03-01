import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('Consent', () {
    const encode = ConsentEncoder.encode;
    const decode = ConsentEncoder.decode;

    final data = readMapData('consent');
    test('check data', () async {
      expect(data.length, 4);
    });
    final noData = data[0];
    final noLegitimateInterestData = data[1];
    final minData = data[2];
    final fullData = data[3];

    group('encode', () {
      test('min', () async {
        const consent = Consent(
          id: 'mock-id',
          legitimateInterest: true,
          sources: ConsentSources(
            createdFromCRM: false,
            imported: true,
            fromConsentPage: false,
            privateAPI: true,
            publicAPI: false,
            trackedFromScenario: true,
          ),
          translations: {},
        );
        expect(encode(consent), minData);
      });

      test('full', () async {
        const consent = Consent(
          id: 'mock-id',
          legitimateInterest: true,
          sources: ConsentSources(
            createdFromCRM: false,
            imported: true,
            fromConsentPage: false,
            privateAPI: true,
            publicAPI: false,
            trackedFromScenario: true,
          ),
          translations: {
            "cz": {"test": "aaaa", "desc": ""},
          },
        );
        expect(encode(consent), fullData);
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

      test('no legitimateInterest', () async {
        try {
          decode(noLegitimateInterestData);
          fail('Should throw exception');
        } on StateError catch (err) {
          expect(err.message, 'legitimateInterest is required!');
        } catch (err) {
          fail('No other errors');
        }
      });

      test('min', () async {
        const expected = Consent(
          id: 'mock-id',
          legitimateInterest: true,
          sources: ConsentSources(
            createdFromCRM: false,
            imported: true,
            fromConsentPage: false,
            privateAPI: true,
            publicAPI: false,
            trackedFromScenario: true,
          ),
          translations: {},
        );
        final decoded = decode(minData);

        expect(decoded.id, expected.id);
        expect(decoded.legitimateInterest, expected.legitimateInterest);
        expect(decoded.sources.createdFromCRM, expected.sources.createdFromCRM);
        expect(decoded.sources.imported, expected.sources.imported);
        expect(
            decoded.sources.fromConsentPage, expected.sources.fromConsentPage);
        expect(decoded.sources.privateAPI, expected.sources.privateAPI);
        expect(decoded.sources.publicAPI, expected.sources.publicAPI);
        expect(decoded.sources.trackedFromScenario,
            expected.sources.trackedFromScenario);
        expect(decoded.translations, expected.translations);
      });

      test('full', () async {
        const expected = Consent(
          id: 'mock-id',
          legitimateInterest: true,
          sources: ConsentSources(
            createdFromCRM: false,
            imported: true,
            fromConsentPage: false,
            privateAPI: true,
            publicAPI: false,
            trackedFromScenario: true,
          ),
          translations: {
            "cz": {"test": "aaaa", "desc": ""},
          },
        );
        final decoded = decode(fullData);

        expect(decoded.id, expected.id);
        expect(decoded.legitimateInterest, expected.legitimateInterest);
        expect(decoded.sources.createdFromCRM, expected.sources.createdFromCRM);
        expect(decoded.sources.imported, expected.sources.imported);
        expect(
            decoded.sources.fromConsentPage, expected.sources.fromConsentPage);
        expect(decoded.sources.privateAPI, expected.sources.privateAPI);
        expect(decoded.sources.publicAPI, expected.sources.publicAPI);
        expect(decoded.sources.trackedFromScenario,
            expected.sources.trackedFromScenario);
        expect(decoded.translations, expected.translations);
      });
    });
  });
}
