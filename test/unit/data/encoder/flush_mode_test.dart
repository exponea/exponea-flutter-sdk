import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlushModeEncoder', () {
    final encode = FlushModeEncoder.encode;
    final decode = FlushModeEncoder.decode;

    test('encode', () async {
      expect(encode(FlushMode.immediate), 'IMMEDIATE');
      expect(encode(FlushMode.period), 'PERIOD');
      expect(encode(FlushMode.appClose), 'APP_CLOSE');
      expect(encode(FlushMode.manual), 'MANUAL');
    });

    test('decode', () async {
      expect(decode('IMMEDIATE'), FlushMode.immediate);
      expect(decode('PERIOD'), FlushMode.period);
      expect(decode('APP_CLOSE'), FlushMode.appClose);
      expect(decode('MANUAL'), FlushMode.manual);
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
