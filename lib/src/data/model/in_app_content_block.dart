import 'package:meta/meta.dart';

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
        '}';
  }
}
