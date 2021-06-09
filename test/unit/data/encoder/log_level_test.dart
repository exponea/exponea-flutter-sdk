import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogLevelEncoder', () {
    final encode = LogLevelEncoder.encode;
    final decode = LogLevelEncoder.decode;

    test('encode', () async {
      expect(encode(LogLevel.off), 'OFF');
      expect(encode(LogLevel.error), 'ERROR');
      expect(encode(LogLevel.warning), 'WARN');
      expect(encode(LogLevel.info), 'INFO');
      expect(encode(LogLevel.debug), 'DEBUG');
      expect(encode(LogLevel.verbose), 'VERBOSE');
    });

    test('decode', () async {
      expect(decode('OFF'), LogLevel.off);
      expect(decode('ERROR'), LogLevel.error);
      expect(decode('WARN'), LogLevel.warning);
      expect(decode('WARNING'), LogLevel.warning);
      expect(decode('INFO'), LogLevel.info);
      expect(decode('DEBUG'), LogLevel.debug);
      expect(decode('VERBOSE'), LogLevel.verbose);
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
