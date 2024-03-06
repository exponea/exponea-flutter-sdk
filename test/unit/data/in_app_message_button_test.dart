import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('InAppMessageButton', () {
    const encode = InAppMessageButtonEncoder.encode;
    const decode = InAppMessageButtonEncoder.decode;

    final data = readMapData('in_app_message_button');
    test('check data', () async {
      expect(data.length, 3);
    });
    final noData = data[0];
    final textOnlyData = data[1];
    final fullData = data[2];

    group('encode', () {
      test('no data', () {
        const inAppMessageButton = InAppMessageButton();
        expect(encode(inAppMessageButton), noData);
      });

      test('text only', () async {
        const inAppMessageButton = InAppMessageButton(text: 'button');
        expect(encode(inAppMessageButton), textOnlyData);
      });

      test('full data', () async {
        const inAppMessageButton = InAppMessageButton(text: 'button', url: 'https://a.b.c');
        expect(encode(inAppMessageButton), fullData);
      });
    });

    group('decode', () {
      test('no data', () async {
        const expected = InAppMessageButton();
        final decoded = decode(noData);

        expect(decoded.text, null);
        expect(decoded.url, null);
      });

      test('text only', () async {
        final decoded = decode(textOnlyData);

        expect(decoded.text, 'button');
        expect(decoded.url, null);
      });

      test('full data', () async {
        final decoded = decode(fullData);

        expect(decoded.text, 'button');
        expect(decoded.url, 'https://a.b.c');
      });
    });
  });
}
