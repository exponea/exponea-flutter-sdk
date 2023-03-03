
abstract class Encodable {
  /// Returns encoded Map without NULL values
  Map<String, dynamic> encodeClean() {
    return encode()..removeWhere((key, value) => value == null);
  }
  Map<String, dynamic> encode();
}
