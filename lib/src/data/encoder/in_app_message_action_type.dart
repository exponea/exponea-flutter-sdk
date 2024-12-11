import '../model/in_app_message_action_type.dart';

abstract class InAppMessageActionTypeEncoder {
  static String encode(InAppMessageActionType action) {
    switch (action) {
      case InAppMessageActionType.click:
        return 'click';
      case InAppMessageActionType.close:
        return 'close';
      case InAppMessageActionType.error:
        return 'error';
      case InAppMessageActionType.show:
        return 'show';
    }
  }

  static InAppMessageActionType decode(String value) {
    switch (value) {
      case 'click':
        return InAppMessageActionType.click;
      case 'close':
        return InAppMessageActionType.close;
      case 'error':
        return InAppMessageActionType.error;
      case 'show':
        return InAppMessageActionType.show;
      default:
        throw UnsupportedError('`$value` is not a InAppMessageActionType!');
    }
  }
}
