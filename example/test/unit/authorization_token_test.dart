import 'package:exponea_example/util/authorization_token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeAuthorizationToken', () {
    test('strips leading Token prefix', () {
      expect(normalizeAuthorizationToken('Token abc123'), 'abc123');
      expect(normalizeAuthorizationToken('token abc123'), 'abc123');
      expect(normalizeAuthorizationToken('TOKEN  abc123'), 'abc123');
    });

    test('leaves raw token unchanged', () {
      expect(normalizeAuthorizationToken('abc123'), 'abc123');
      expect(normalizeAuthorizationToken('  abc123  '), 'abc123');
    });

    test('does not strip Token without trailing space', () {
      expect(normalizeAuthorizationToken('Tokenabc'), 'Tokenabc');
    });
  });
}
