import 'package:flutter_test/flutter_test.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:exponea/exponea.dart';

void main() {
  group('InAppContentBlockActionTypeEncoder', () {
    const encode = InAppContentBlockActionTypeEncoder.encode;
    const decode = InAppContentBlockActionTypeEncoder.decode;

    final data = [
      {'type': 'DEEPLINK'},
      {'type': 'BROWSER'},
      {'type': 'CLOSE'}
    ];

    test('check data', () async {
      expect(data.length, 3);
    });

    group('encode', () {
      test('encode deeplink', () async {
        expect(encode(InAppContentBlockActionType.deeplink), 'DEEPLINK');
      });

      test('encode browser', () async {
        expect(encode(InAppContentBlockActionType.browser), 'BROWSER');
      });

      test('encode close', () async {
        expect(encode(InAppContentBlockActionType.close), 'CLOSE');
      });
    });

    group('decode', () {
      test('decode deeplink', () async {
        expect(decode('DEEPLINK'), InAppContentBlockActionType.deeplink);
      });

      test('decode browser', () async {
        expect(decode('BROWSER'), InAppContentBlockActionType.browser);
      });

      test('decode close', () async {
        expect(decode('CLOSE'), InAppContentBlockActionType.close);
      });

      test('decode unsupported value', () async {
        expect(() => decode('INVALID'), throwsUnsupportedError);
      });
    });
  });
}