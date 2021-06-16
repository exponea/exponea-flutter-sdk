import 'package:meta/meta.dart';

import '../model/push.dart';
import '../util/object.dart';
import 'push_type.dart';

@immutable
class OpenedPushEncoder {
  static OpenedPush decode(Map<String, dynamic> data) {
    return OpenedPush(
      action: PushActionTypeEncoder.decode(data.getRequired('action')),
      url: data.getOptional('url'),
      additionalData: data.getOptional('additionalData'),
    );
  }

  static Map<String, dynamic> encode(OpenedPush push) {
    return {
      'action': PushActionTypeEncoder.encode(push.action),
      'url': push.url,
      'additionalData': push.additionalData,
    }..removeWhere((key, value) => value == null);
  }
}
