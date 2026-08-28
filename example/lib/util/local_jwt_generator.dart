import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Demo-only JWT generator for the example app (HMAC-SHA512).
///
/// Production apps must generate tokens on a secure backend.
class LocalJwtTokenGenerator {
  LocalJwtTokenGenerator._();

  static final LocalJwtTokenGenerator instance = LocalJwtTokenGenerator._();

  static const defaultExpirationMinutes = 15;

  String _secret = '';
  String _kid = '';

  void configure({required String secret, required String kid}) {
    _secret = secret;
    _kid = kid;
  }

  bool get isConfigured => _secret.isNotEmpty && _kid.isNotEmpty;

  String? generateToken(Map<String, String> customerIds) {
    if (_secret.isEmpty || _kid.isEmpty) {
      return null;
    }
    if (customerIds.isEmpty) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiresAt = now + defaultExpirationMinutes * 60;
    final header = _base64UrlStr(
      jsonEncode({'typ': 'JWT', 'alg': 'HS512', 'kid': _kid}),
    );
    final payload = _base64UrlStr(
      jsonEncode({'exp': expiresAt, 'ids': customerIds}),
    );
    final signingInput = '$header.$payload';
    final signature = Hmac(sha512, utf8.encode(_secret))
        .convert(utf8.encode(signingInput))
        .bytes;
    return '$signingInput.${_base64Url(signature)}';
  }

  static String _base64Url(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String _base64UrlStr(String value) {
    return _base64Url(utf8.encode(value));
  }
}
