import 'package:meta/meta.dart';

import '../model/in_app_message_action.dart';
import '../util/object.dart';
import 'in_app_message.dart';
import 'in_app_message_action_type.dart';
import 'in_app_message_button.dart';

@immutable
class InAppMessageActionEncoder {
  static InAppMessageAction decode(Map<dynamic, dynamic> data) {
    return InAppMessageAction(
      type: InAppMessageActionTypeEncoder.decode(data.getRequired('type')),
      message: data.getOptional<Map<dynamic, dynamic>>('message')?.let(InAppMessageEncoder.decode),
      button: data.getOptional<Map<dynamic, dynamic>>('button')?.let(InAppMessageButtonEncoder.decode),
      interaction: data.getOptional('interaction'),
      errorMessage: data.getOptional('errorMessage'),
    );
  }

  static Map<String, dynamic> encode(InAppMessageAction action) {
    return {
      'type': InAppMessageActionTypeEncoder.encode(action.type),
      'message': action.message?.let(InAppMessageEncoder.encode),
      'button': action.button?.let(InAppMessageButtonEncoder.encode),
      'interaction': action.interaction,
      'errorMessage': action.errorMessage,
    }..removeWhere((key, value) => value == null);
  }
}
