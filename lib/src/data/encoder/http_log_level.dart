import '../model/http_log_level.dart';

abstract class HttpLoggingLevelEncoder {
  static String encode(HttpLoggingLevel level) {
    switch (level) {
      case HttpLoggingLevel.none:
        return 'NONE';
      case HttpLoggingLevel.basic:
        return 'BASIC';
      case HttpLoggingLevel.headers:
        return 'HEADERS';
      case HttpLoggingLevel.body:
        return 'BODY';
    }
  }

  static HttpLoggingLevel decode(String value) {
    switch (value) {
      case 'NONE':
        return HttpLoggingLevel.none;
      case 'BASIC':
        return HttpLoggingLevel.basic;
      case 'HEADERS':
        return HttpLoggingLevel.headers;
      case 'BODY':
        return HttpLoggingLevel.body;
      default:
        throw UnsupportedError('`$value` is not a HttpLoggingLevel!');
    }
  }
}
