import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenFrequencyEncoder', () {
    final encode = TokenFrequencyEncoder.encode;
    final decode = TokenFrequencyEncoder.decode;

    test('encode', () async {
      expect(encode(TokenFrequency.onTokenChange), 'ON_TOKEN_CHANGE');
      expect(encode(TokenFrequency.everyLaunch), 'EVERY_LAUNCH');
      expect(encode(TokenFrequency.daily), 'DAILY');
    });

    test('decode', () async {
      expect(decode('ON_TOKEN_CHANGE'), TokenFrequency.onTokenChange);
      expect(decode('EVERY_LAUNCH'), TokenFrequency.everyLaunch);
      expect(decode('DAILY'), TokenFrequency.daily);
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
