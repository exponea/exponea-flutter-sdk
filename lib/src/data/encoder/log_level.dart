import '../model/log_level.dart';

abstract class LogLevelEncoder {
  static String encode(LogLevel level) {
    switch (level) {
      case LogLevel.off:
        return 'OFF';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.verbose:
        return 'VERBOSE';
    }
  }

  static LogLevel decode(String value) {
    switch (value) {
      case 'OFF':
        return LogLevel.off;
      case 'ERROR':
        return LogLevel.error;
      case 'WARN':
      case 'WARNING':
        return LogLevel.warning;
      case 'INFO':
        return LogLevel.info;
      case 'DEBUG':
        return LogLevel.debug;
      case 'VERBOSE':
        return LogLevel.verbose;
      default:
        throw UnsupportedError('`$value` is not a LogLevel!');
    }
  }
}
