import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('LogLevel', () {
    const encode = LogLevelEncoder.encode;
    const decode = LogLevelEncoder.decode;

    final data = readStringData('log_level');
    test('check data', () async {
      expect(data.length, 6);
    });

    test('encode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(encode(LogLevel.values[i]), data[i]);
      }
    });

    test('decode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(decode(data[i]), LogLevel.values[i]);
      }
      expect(decode('WARNING'), LogLevel.warning);
      expect(() => decode('FOO'), throwsUnsupportedError);
      expect(() => decode('foo'), throwsUnsupportedError);
    });
  });
}
