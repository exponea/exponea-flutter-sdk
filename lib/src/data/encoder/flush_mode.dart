import '../model/flush_mode.dart';

abstract class FlushModeEncoder {
  static String encode(FlushMode mode) {
    switch (mode) {
      case FlushMode.period:
        return 'PERIOD';
      case FlushMode.appClose:
        return 'APP_CLOSE';
      case FlushMode.manual:
        return 'MANUAL';
      case FlushMode.immediate:
        return 'IMMEDIATE';
    }
  }

  static FlushMode decode(String value) {
    switch (value) {
      case 'PERIOD':
        return FlushMode.period;
      case 'APP_CLOSE':
        return FlushMode.appClose;
      case 'MANUAL':
        return FlushMode.manual;
      case 'IMMEDIATE':
        return FlushMode.immediate;
      default:
        throw UnsupportedError('`$value` is not a FlushMode!');
    }
  }
}
