import '../model/notification_importance.dart';

abstract class PushNotificationImportanceEncoder {
  static String encode(PushNotificationImportance importance) {
    switch (importance) {
      case PushNotificationImportance.min:
        return 'MIN';
      case PushNotificationImportance.low:
        return 'LOW';
      case PushNotificationImportance.normal:
        return 'DEFAULT';
      case PushNotificationImportance.high:
        return 'HIGH';
    }
  }

  static PushNotificationImportance decode(String value) {
    switch (value) {
      case 'MIN':
        return PushNotificationImportance.min;
      case 'LOW':
        return PushNotificationImportance.low;
      case 'DEFAULT':
      case 'NORMAL':
        return PushNotificationImportance.normal;
      case 'HIGH':
        return PushNotificationImportance.high;
      default:
        throw UnsupportedError('`$value` is not a PushNotificationImportance!');
    }
  }
}
