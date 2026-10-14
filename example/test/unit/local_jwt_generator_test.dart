import 'dart:convert';

import 'package:exponea_example/util/local_jwt_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final generator = LocalJwtTokenGenerator.instance;

  setUp(() {
    generator.configure(secret: 'test-secret', kid: 'test-kid');
  });

  tearDown(() {
    // Reset to unconfigured state between tests.
    generator.configure(secret: '', kid: '');
  });

  group('LocalJwtTokenGenerator.isConfigured', () {
    test('false when secret and kid are empty', () {
      generator.configure(secret: '', kid: '');
      expect(generator.isConfigured, isFalse);
    });

    test('false when only secret is set', () {
      generator.configure(secret: 'some-secret', kid: '');
      expect(generator.isConfigured, isFalse);
    });

    test('false when only kid is set', () {
      generator.configure(secret: '', kid: 'some-kid');
      expect(generator.isConfigured, isFalse);
    });

    test('true after configure with non-empty secret and kid', () {
      expect(generator.isConfigured, isTrue);
    });
  });

  group('LocalJwtTokenGenerator.generateToken', () {
    test('returns null when generator is not configured', () {
      generator.configure(secret: '', kid: '');
      expect(generator.generateToken({'registered': 'user@example.com'}), isNull);
    });

    test('returns null for empty customerIds', () {
      expect(generator.generateToken({}), isNull);
    });

    test('generated token has exactly 3 dot-separated parts', () {
      final token = generator.generateToken({'registered': 'user@example.com'});
      expect(token, isNotNull);
      final parts = token!.split('.');
      expect(parts.length, equals(3));
      expect(parts[0], isNotEmpty);
      expect(parts[1], isNotEmpty);
      expect(parts[2], isNotEmpty);
    });

    test('decoded header contains alg HS512 and correct kid', () {
      final token = generator.generateToken({'registered': 'user@example.com'})!;
      final headerJson = _decodeBase64UrlPart(token.split('.')[0]);
      expect(headerJson['alg'], equals('HS512'));
      expect(headerJson['kid'], equals('test-kid'));
      expect(headerJson['typ'], equals('JWT'));
    });

    test('decoded payload contains ids matching input customerIds', () {
      final customerIds = {'registered': 'user@example.com', 'email': 'user@example.com'};
      final token = generator.generateToken(customerIds)!;
      final payloadJson = _decodeBase64UrlPart(token.split('.')[1]);
      expect(payloadJson['ids'], equals(customerIds));
    });

    test('decoded payload exp is in the future', () {
      final token = generator.generateToken({'registered': 'user@example.com'})!;
      final payloadJson = _decodeBase64UrlPart(token.split('.')[1]);
      final exp = payloadJson['exp'] as int;
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      expect(exp, greaterThan(nowSeconds));
    });

    test('decoded payload exp is approximately 15 minutes from now', () {
      final token = generator.generateToken({'registered': 'user@example.com'})!;
      final payloadJson = _decodeBase64UrlPart(token.split('.')[1]);
      final exp = payloadJson['exp'] as int;
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const expectedMinutes = LocalJwtTokenGenerator.defaultExpirationMinutes;
      expect(exp - nowSeconds, closeTo(expectedMinutes * 60, 5));
    });
  });
}

Map<String, dynamic> _decodeBase64UrlPart(String base64UrlPart) {
  // Restore Base64 padding before decoding.
  final padded = base64UrlPart.padRight(
    base64UrlPart.length + (4 - base64UrlPart.length % 4) % 4,
    '=',
  );
  final decoded = utf8.decode(base64Url.decode(padded));
  return jsonDecode(decoded) as Map<String, dynamic>;
}
