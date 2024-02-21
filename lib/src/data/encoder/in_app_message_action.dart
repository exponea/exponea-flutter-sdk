import 'package:meta/meta.dart';

import '../model/in_app_message_action.dart';
import '../util/object.dart';
import 'in_app_message.dart';
import 'in_app_message_button.dart';

@immutable
class InAppMessageActionEncoder {
  static InAppMessageAction decode(Map<dynamic, dynamic> data) {
    return InAppMessageAction(
      message: InAppMessageEncoder.decode(data.getRequired<Map<dynamic, dynamic>>('message')),
      button: data.getOptional<Map<dynamic, dynamic>>('button')?.let(InAppMessageButtonEncoder.decode),
      interaction: data.getRequired('interaction'),
    );
  }

  static Map<String, dynamic> encode(InAppMessageAction action) {
    return {
      'message': InAppMessageEncoder.encode(action.message),
      'button': action.button?.let(InAppMessageButtonEncoder.encode),
      'interaction': action.interaction,
    }..removeWhere((key, value) => value == null);
  }
}
