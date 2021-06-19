import 'package:meta/meta.dart';

import '../model/push_opened.dart';
import '../util/object.dart';
import 'push_type.dart';

@immutable
class OpenedPushEncoder {
  static OpenedPush decode(Map<dynamic, dynamic> data) {
    return OpenedPush(
      action: PushActionTypeEncoder.decode(data.getRequired('action')),
      url: data.getOptional('url'),
      data: data
          .getOptional<Map>('data')
          ?.map((key, value) => MapEntry(key?.toString() ?? '', value)),
    );
  }

  static Map<String, dynamic> encode(OpenedPush push) {
    return {
      'action': PushActionTypeEncoder.encode(push.action),
      'url': push.url,
      'data': push.data,
    }..removeWhere((key, value) => value == null);
  }
}
