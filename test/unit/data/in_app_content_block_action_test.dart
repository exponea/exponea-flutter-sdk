import 'package:flutter_test/flutter_test.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:exponea/exponea.dart';

import 'base.dart';

void main() {
  group('InAppContentBlockAction', () {
    const encode = InAppContentBlockActionEncoder.encode;
    const decode = InAppContentBlockActionEncoder.decode;

    final data = readMapData('in_app_content_block_action');
    test('check data', () async {
      expect(data.length, 4);
    });

    final noData = data[0];
    final minimalData = data[1];
    final withNameData = data[2];
    final fullData = data[3];

    group('encode', () {
      test('minimal', () async {
        const action = InAppContentBlockAction(
          type: InAppContentBlockActionType.browser,
        );
        expect(encode(action), minimalData);
      });

      test('with name value', () async {
        const action = InAppContentBlockAction(
          type: InAppContentBlockActionType.browser,
          name: 'mock-name',
        );
        expect(encode(action), withNameData);
      });

      test('full data', () async {
        const action = InAppContentBlockAction(
          type: InAppContentBlockActionType.browser,
          name: 'mock-name',
          url: 'https://mock-url.com',
        );
        expect(encode(action), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        expect(() => decode(noData), throwsStateError);
      });

      test('minimal', () async {
        final decoded = decode(minimalData);
        expect(decoded.type, InAppContentBlockActionType.browser);
        expect(decoded.name, null);
        expect(decoded.url, null);
      });

      test('with name value', () async {
        final decoded = decode(withNameData);
        expect(decoded.type, InAppContentBlockActionType.browser);
        expect(decoded.name, 'mock-name');
        expect(decoded.url, null);
      });

      test('full data', () async {
        final decoded = decode(fullData);
        expect(decoded.type, InAppContentBlockActionType.browser);
        expect(decoded.name, 'mock-name');
        expect(decoded.url, 'https://mock-url.com');
      });
    });
  });
}