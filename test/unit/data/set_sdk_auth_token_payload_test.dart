import 'package:exponea/src/data/normalization/set_sdk_auth_token_payload.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('encodeSetSdkAuthTokenPayload', () {
    final data = readMapData('set_sdk_auth_token_payload');

    test('check data', () {
      expect(data.length, 1);
    });

    test('encodes token', () {
      expect(
        encodeSetSdkAuthTokenPayload('mock-jwt-token'),
        data[0],
      );
    });
  });
}
