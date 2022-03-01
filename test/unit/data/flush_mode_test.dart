import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('FlushMode', () {
    const encode = FlushModeEncoder.encode;
    const decode = FlushModeEncoder.decode;

    final data = readStringData('flush_mode');
    test('check data', () async {
      expect(data.length, 4);
    });

    test('encode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(encode(FlushMode.values[i]), data[i]);
      }
    });

    test('decode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(decode(data[i]), FlushMode.values[i]);
      }
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
