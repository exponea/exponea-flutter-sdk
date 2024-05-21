import '../model/in_app_content_block_action.dart';
import '../util/object.dart';
import 'in_app_content_block_action_type.dart';

abstract class InAppContentBlockActionEncoder {
  static InAppContentBlockAction decode(Map<dynamic, dynamic> data) {
    return InAppContentBlockAction(
      type: InAppContentBlockActionTypeEncoder.decode(data.getRequired('type')),
      name: data.getOptional('name'),
      url: data.getOptional('url'),
    );
  }

  static Map<String, dynamic> encode(InAppContentBlockAction action) {
    return {
      'type': InAppContentBlockActionTypeEncoder.encode(action.type),
      'name': action.name,
      'url': action.url,
    }..removeWhere((key, value) => value == null);
  }
}