import 'package:meta/meta.dart';

import '../model/in_app_message_button.dart';
import '../util/object.dart';

@immutable
class InAppMessageButtonEncoder {
  static InAppMessageButton decode(Map<dynamic, dynamic> data) {
    return InAppMessageButton(
      text: data.getOptional('text'),
      url: data.getOptional('url'),
    );
  }

  static Map<String, dynamic> encode(InAppMessageButton button) {
    return {
      'text': button.text,
      'url': button.url,
    }..removeWhere((key, value) => value == null);
  }
}
