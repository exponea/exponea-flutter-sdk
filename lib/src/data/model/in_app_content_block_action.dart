import 'package:meta/meta.dart';

import 'in_app_content_block_action_type.dart';

@immutable
class InAppContentBlockAction {
  final InAppContentBlockActionType type;
  final String? name;
  final String? url;

  const InAppContentBlockAction({
    required this.type,
    this.name,
    this.url,
  });

  @override
  String toString() {
    return 'InAppContentBlockAction{type: $type, name: $name, url: $url}';
  }
}
