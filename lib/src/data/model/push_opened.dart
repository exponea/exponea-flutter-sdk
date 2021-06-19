import 'package:meta/meta.dart';

import 'push_type.dart';

@immutable
class OpenedPush {
  final PushActionType action;
  final String? url;

  /// Additional data defined on Exponea web app when creating the push
  final Map<String, dynamic>? data;

  const OpenedPush({
    required this.action,
    this.url,
    this.data,
  });

  @override
  String toString() {
    return 'OpenedPush{action: $action, url: $url, data: $data}';
  }
}
