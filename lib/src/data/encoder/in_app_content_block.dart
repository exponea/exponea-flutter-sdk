import '../model/in_app_content_block.dart';
import '../util/object.dart';

abstract class InAppContentBlockEncoder {
  static InAppContentBlock decode(Map<dynamic, dynamic> data) {
    return InAppContentBlock(
      id: data.getRequired('id'),
      name: data.getRequired('name'),
      dateFilter: data.getOptional("date_filter"),
      frequency: data.getOptional('frequency'),
      loadPriority: data.getOptional('load_priority'),
      consentCategoryTracking: data.getOptional('consent_category_tracking'),
      contentType: data.getOptional('content_type'),
      content: data.getOptional('content'),
      placeholders: data
          .getRequired<List>('placeholders')
          .map((it) => it.toString())
          .toList(growable: false),
    );
  }

  static Map<String, dynamic> encode(InAppContentBlock contentBlock) {
    return {
      'id': contentBlock.id,
      'name': contentBlock.name,
      'date_filter': contentBlock.dateFilter,
      'frequency': contentBlock.frequency,
      'load_priority': contentBlock.loadPriority,
      'consent_category_tracking': contentBlock.consentCategoryTracking,
      'content_type': contentBlock.contentType,
      'content': contentBlock.content,
      'placeholders': contentBlock.placeholders,
    }..removeWhere((key, value) => value == null);
  }
}
