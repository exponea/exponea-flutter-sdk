import 'package:meta/meta.dart';

import '../model/push_received.dart';
import '../util/object.dart';

@immutable
class ReceivedPushEncoder {
  static ReceivedPush decode(Map<dynamic, dynamic> data) {
    return ReceivedPush(
      data: data
          .getRequired<Map>('data')
          .map((key, value) => MapEntry(key?.toString() ?? '', value)),
    );
  }

  static Map<String, dynamic> encode(ReceivedPush push) {
    return {
      'data': push.data,
    };
  }
}
