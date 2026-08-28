import 'package:exponea/src/data/encoder/sdk_auth_error.dart';
import 'package:exponea/src/data/model/sdk_auth_error.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('SdkAuthErrorCode', () {
    const encode = SdkAuthErrorCodeEncoder.encode;
    const decode = SdkAuthErrorCodeEncoder.decode;

    final wireValues = readStringData('sdk_auth_error_code');

    test('check data', () {
      expect(wireValues.length, SdkAuthErrorCode.values.length);
    });

    test('encode', () {
      for (var i = 0; i < wireValues.length; i++) {
        expect(encode(SdkAuthErrorCode.values[i]), wireValues[i]);
      }
    });

    test('decode', () {
      for (var i = 0; i < wireValues.length; i++) {
        expect(decode(wireValues[i]), SdkAuthErrorCode.values[i]);
      }
      expect(() => decode('TOKEN_UNKNOWN'), throwsUnsupportedError);
    });
  });

  group('SdkAuthError', () {
    const encode = SdkAuthErrorEncoder.encode;
    const decode = SdkAuthErrorEncoder.decode;

    final data = readMapData('sdk_auth_error');

    test('check data', () {
      expect(data.length, SdkAuthErrorCode.values.length);
    });

    test('encode round-trip', () {
      for (var i = 0; i < data.length; i++) {
        expect(encode(decode(data[i])), data[i]);
      }
    });

    test('decode fixtures', () {
      final aboutToExpire = decode(data[0]);
      expect(aboutToExpire.errorCode, SdkAuthErrorCode.tokenAboutToExpire);
      expect(aboutToExpire.customerIds['registered'], 'user@example.com');

      final insufficient = decode(data[4]);
      expect(insufficient.errorCode, SdkAuthErrorCode.tokenInsufficient);
      expect(insufficient.customerIds['registered'], 'user@example.com');
    });
  });
}
