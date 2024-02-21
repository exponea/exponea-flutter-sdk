import 'package:meta/meta.dart';

import 'in_app_message.dart';
import 'in_app_message_button.dart';

@immutable
class InAppMessageAction {
  final InAppMessage message;
  final InAppMessageButton? button;
  final bool interaction;

  const InAppMessageAction({
    required this.message,
    this.button,
    required this.interaction,
  });

  @override
  String toString() {
    return 'InAppMessageAction{message: $message, button: $button, interaction: $interaction}';
  }
}
