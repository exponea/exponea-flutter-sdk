/// Normalizes an Exponea project authorization token for the Flutter SDK.
///
/// Native Android example apps keep a leading `Token ` prefix because the native
/// SDK expects the full Authorization header value. The Flutter plugin prepends
/// the scheme itself, so a double prefix silently breaks uploads.
String normalizeAuthorizationToken(String value) {
  final trimmed = value.trim();
  if (trimmed.length < 6) {
    return trimmed;
  }
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('token ')) {
    return trimmed.substring(6).trimLeft();
  }
  return trimmed;
}
