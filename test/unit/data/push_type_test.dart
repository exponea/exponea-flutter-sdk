import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('PushActionType', () {
    const encode = PushActionTypeEncoder.encode;
    const decode = PushActionTypeEncoder.decode;

    final data = readStringData('push_type');
    test('check data', () async {
      expect(data.length, 3);
    });

    test('encode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(encode(PushActionType.values[i]), data[i]);
      }
    });

    test('decode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(decode(data[i]), PushActionType.values[i]);
      }
      expect(() => decode('foo'), throwsUnsupportedError);
    });
  });
}
