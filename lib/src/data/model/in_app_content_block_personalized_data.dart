import 'package:meta/meta.dart';

@immutable
class InAppContentBlockPersonalizedData {
  final String id;
  final String? status;
  final int? timeToLive;
  final bool? hasTrackingConsent;
  final int? variantId;
  final String? variantName;
  final String? contentType;
  final Map<String, dynamic>? content;
  final String? loadedAt;


  const InAppContentBlockPersonalizedData({
    required this.id,
    this.status,
    this.timeToLive,
    this.hasTrackingConsent,
    this.variantId,
    this.variantName,
    this.contentType,
    this.content,
    this.loadedAt,
  });

  @override
  String toString() {
    return 'InAppContentBlockPersonalizedData{'
        'id: $id, '
        'status: $status, '
        'timeToLive: $timeToLive, '
        'hasTrackingConsent: $hasTrackingConsent, '
        'variantId: $variantId, '
        'variantName: $variantName, '
        'contentType: $contentType, '
        'content: $content, '
        'loadedAt: $loadedAt'
        '}';
  }
}
