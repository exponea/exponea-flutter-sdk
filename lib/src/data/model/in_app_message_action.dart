import 'package:meta/meta.dart';

import 'in_app_message.dart';
import 'in_app_message_action_type.dart';
import 'in_app_message_button.dart';

@immutable
class InAppMessageAction {
  final InAppMessageActionType type;
  final InAppMessage? message;
  final InAppMessageButton? button;
  final bool? interaction;
  final String? errorMessage;

  const InAppMessageAction({
    required this.type,
    this.message,
    this.button,
    this.interaction,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'InAppMessageAction{type: $type, message: $message, button: $button, interaction: $interaction, errorMessage: $errorMessage}';
  }
}
