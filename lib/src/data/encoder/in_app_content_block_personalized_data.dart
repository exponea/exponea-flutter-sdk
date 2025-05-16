import '../model/in_app_content_block_personalized_data.dart';
import '../util/object.dart';

abstract class InAppContentBlockPersonalizedDataEncoder {
  static InAppContentBlockPersonalizedData decode(Map<dynamic, dynamic> data) {
    return InAppContentBlockPersonalizedData(
      id: data.getRequired('id'),
      status: data.getOptional('status'),
      timeToLive: data.getOptional('ttl_seconds'),
      hasTrackingConsent: data.getOptional('has_tracking_consent'),
      variantId: data.getOptional('variant_id'),
      variantName: data.getOptional('variant_name'),
      contentType: data.getOptional('content_type'),
      content: data.getOptional('content'),
      loadedAt: data.getOptional('loadedAt'),
    );
  }

  static Map<String, dynamic> encode(InAppContentBlockPersonalizedData contentBlockPersonalizedData) {
    return {
      'id': contentBlockPersonalizedData.id,
      'status': contentBlockPersonalizedData.status,
      'ttl_seconds': contentBlockPersonalizedData.timeToLive,
      'has_tracking_consent': contentBlockPersonalizedData.hasTrackingConsent,
      'variant_id': contentBlockPersonalizedData.variantId,
      'variant_name': contentBlockPersonalizedData.variantName,
      'content_type': contentBlockPersonalizedData.contentType,
      'content': contentBlockPersonalizedData.content,
      'loadedAt': contentBlockPersonalizedData.loadedAt,
    }..removeWhere((key, value) => value == null);
  }
}
