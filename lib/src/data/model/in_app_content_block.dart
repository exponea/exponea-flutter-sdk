import 'package:meta/meta.dart';

import 'in_app_content_block_personalized_data.dart';

@immutable
class InAppContentBlock {
  final String id;
  final String name;
  final Map<String, dynamic>? dateFilter;
  final String? frequency;
  final int? loadPriority;
  final String? consentCategoryTracking;
  final String? contentType;
  final Map<String, dynamic>? content;
  final List<String> placeholders;
  final Map<String, dynamic>? customerIds;
  final InAppContentBlockPersonalizedData? personalizedData;

  const InAppContentBlock({
    required this.id,
    required this.name,
    this.dateFilter,
    this.frequency,
    this.loadPriority,
    this.consentCategoryTracking,
    this.contentType,
    this.content,
    required this.placeholders,
    this.customerIds,
    this.personalizedData,
  });

  @override
  String toString() {
    return 'InAppContentBlock{'
        'id: $id, '
        'name: $name, '
        'dateFilter: $dateFilter, '
        'frequency: $frequency, '
        'loadPriority: $loadPriority, '
        'consentCategoryTracking: $consentCategoryTracking, '
        'contentType: $contentType, '
        'content: $content, '
        'placeholders: $placeholders, '
        'customerIds: $customerIds, '
        'personalizedData: $personalizedData'
        '}';
  }
}
