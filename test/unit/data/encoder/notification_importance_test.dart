import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushNotificationImportanceEncoder', () {
    final encode = PushNotificationImportanceEncoder.encode;
    final decode = PushNotificationImportanceEncoder.decode;

    test('encode', () async {
      expect(encode(PushNotificationImportance.min), 'MIN');
      expect(encode(PushNotificationImportance.low), 'LOW');
      expect(encode(PushNotificationImportance.normal), 'DEFAULT');
      expect(encode(PushNotificationImportance.high), 'HIGH');
    });

    test('decode', () async {
      expect(decode('MIN'), PushNotificationImportance.min);
      expect(decode('LOW'), PushNotificationImportance.low);
      expect(decode('DEFAULT'), PushNotificationImportance.normal);
      expect(decode('NORMAL'), PushNotificationImportance.normal);
      expect(decode('HIGH'), PushNotificationImportance.high);
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
