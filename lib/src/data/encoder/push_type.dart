import '../model/push_type.dart';

abstract class PushActionTypeEncoder {
  static String encode(PushActionType action) {
    switch (action) {
      case PushActionType.app:
        return 'app';
      case PushActionType.deeplink:
        return 'deeplink';
      case PushActionType.web:
        return 'web';
    }
  }

  static PushActionType decode(String value) {
    switch (value) {
      case 'app':
        return PushActionType.app;
      case 'deeplink':
        return PushActionType.deeplink;
      case 'web':
        return PushActionType.web;
      default:
        throw UnsupportedError('`$value` is not a PushActionType!');
    }
  }
}
