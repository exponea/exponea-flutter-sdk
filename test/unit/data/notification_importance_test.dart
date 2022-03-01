import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('PushNotificationImportance', () {
    const encode = PushNotificationImportanceEncoder.encode;
    const decode = PushNotificationImportanceEncoder.decode;

    final data = readStringData('notification_importance');
    test('check data', () async {
      expect(data.length, 4);
    });

    test('encode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(encode(PushNotificationImportance.values[i]), data[i]);
      }
    });

    test('decode', () async {
      for (int i = 0; i < data.length; i++) {
        expect(decode(data[i]), PushNotificationImportance.values[i]);
      }
      expect(decode('DEFAULT'), PushNotificationImportance.normal);
      expect(() => decode('FOO'), throwsUnsupportedError);
    });
  });
}
