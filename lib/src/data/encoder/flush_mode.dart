import '../model/flush_mode.dart';

abstract class FlushModeEncoder {
  static String encode(FlushMode mode) {
    switch (mode) {
      case FlushMode.immediate:
        return 'IMMEDIATE';
      case FlushMode.period:
        return 'PERIOD';
      case FlushMode.appClose:
        return 'APP_CLOSE';
      case FlushMode.manual:
        return 'MANUAL';
    }
  }

  static FlushMode decode(String value) {
    switch (value) {
      case 'IMMEDIATE':
        return FlushMode.immediate;
      case 'PERIOD':
        return FlushMode.period;
      case 'APP_CLOSE':
        return FlushMode.appClose;
      case 'MANUAL':
        return FlushMode.manual;
      default:
        throw UnsupportedError('`$value` is not a FlushMode!');
    }
  }
}
