import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('HttpLoggingLevel', () {
    const encode = HttpLoggingLevelEncoder.encode;
    const decode = HttpLoggingLevelEncoder.decode;

    final data = readStringData('http_log_level');
    test('check data', () async {
      expect(data.length, 4);
    });

    test('encode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(encode(HttpLoggingLevel.values[i]), data[i]);
      }
    });

    test('decode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(decode(data[i]), HttpLoggingLevel.values[i]);
      }
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
