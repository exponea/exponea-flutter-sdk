import 'package:meta/meta.dart';

@immutable
class AppInboxMessage {
  final String id;
  final String type;
  final bool? isRead;
  final double? createTime;
  final Map<String, dynamic>? content;

  const AppInboxMessage({
      required this.id,
      required this.type,
      this.isRead,
      this.createTime,
      this.content
  });

  @override
  String toString() {
    return 'AppInboxMessage{id: $id, type: $type, isRead: $isRead, createTime: $createTime, content: $content}';
  }
}
