import '../model/in_app_content_block_action_type.dart';

abstract class InAppContentBlockActionTypeEncoder {
  static String encode(InAppContentBlockActionType action) {
    switch (action) {
      case InAppContentBlockActionType.deeplink:
        return 'DEEPLINK';
      case InAppContentBlockActionType.browser:
        return 'BROWSER';
      case InAppContentBlockActionType.close:
        return 'CLOSE';
    }
  }

  static InAppContentBlockActionType decode(String value) {
    switch (value) {
      case 'DEEPLINK':
        return InAppContentBlockActionType.deeplink;
      case 'BROWSER':
        return InAppContentBlockActionType.browser;
      case 'CLOSE':
        return InAppContentBlockActionType.close;
      default:
        throw UnsupportedError('`$value` is not a InAppContentBlockActionType!');
    }
  }
}
