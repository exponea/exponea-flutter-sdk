
import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/util/object.dart';

abstract class AppInboxCoder {
  static Map<String, dynamic> encodeMessage(AppInboxMessage source) {
    return {
      'id': source.id,
      'type': source.type,
      'isRead': source.isRead,
      'createTime': source.createTime,
      'content': source.content,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> encodeAction(AppInboxAction source) {
    return {
      'action': source.action,
      'title': source.title,
      'url': source.url
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> encodeActionMessage(AppInboxAction sourceAction, AppInboxMessage sourceMessage) {
    return {
      'action': encodeAction(sourceAction),
      'message': encodeMessage(sourceMessage)
    }..removeWhere((key, value) => value == null);
  }

  static AppInboxMessage decodeMessage(Map<dynamic, dynamic> source) {
    return AppInboxMessage(
      id: source.getRequired("id"),
      type: source.getRequired("type"),
      isRead: source.getOptional("isRead"),
      createTime: source.getOptional("createTime"),
      content: source.getOptional<Map>("content")
        ?.map((key, value) => MapEntry(key?.toString() ?? '', value)),
    );
  }
}
