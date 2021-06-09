import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpLoggingLevelEncoder', () {
    final encode = HttpLoggingLevelEncoder.encode;
    final decode = HttpLoggingLevelEncoder.decode;

    test('encode', () async {
      expect(encode(HttpLoggingLevel.none), 'NONE');
      expect(encode(HttpLoggingLevel.basic), 'BASIC');
      expect(encode(HttpLoggingLevel.headers), 'HEADERS');
      expect(encode(HttpLoggingLevel.body), 'BODY');
    });

    test('decode', () async {
      expect(decode('NONE'), HttpLoggingLevel.none);
      expect(decode('BASIC'), HttpLoggingLevel.basic);
      expect(decode('HEADERS'), HttpLoggingLevel.headers);
      expect(decode('BODY'), HttpLoggingLevel.body);
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
