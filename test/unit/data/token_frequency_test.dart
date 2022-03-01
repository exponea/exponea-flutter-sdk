import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('TokenFrequency', () {
    const encode = TokenFrequencyEncoder.encode;
    const decode = TokenFrequencyEncoder.decode;

    final data = readStringData('token_frequency');
    test('check data', () async {
      expect(data.length, 3);
    });

    test('encode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(encode(TokenFrequency.values[i]), data[i]);
      }
    });

    test('decode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(decode(data[i]), TokenFrequency.values[i]);
      }
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
