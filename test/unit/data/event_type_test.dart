import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('EventType', () {
    const encode = EventTypeEncoder.encode;
    const decode = EventTypeEncoder.decode;

    final data = readStringData('event_type');
    test('check data', () async {
      expect(data.length, 11);
    });

    test('encode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(encode(EventType.values[i]), data[i]);
      }
    });

    test('decode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(decode(data[i]), EventType.values[i]);
      }
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
