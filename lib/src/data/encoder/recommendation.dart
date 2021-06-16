import '../model/recommendation.dart';
import '../util/object.dart';

abstract class RecommendationOptionsEncoder {
  static RecommendationOptions decode(Map<String, dynamic> data) {
    return RecommendationOptions(
      id: data.getRequired('id'),
      fillWithRandom: data.getRequired('fillWithRandom'),
      size: data.getOptional('size'),
      items: data.getOptional('items'),
      noTrack: data.getOptional('noTrack'),
      catalogAttributesWhitelist:
          data.getOptional('catalogAttributesWhitelist'),
    );
  }

  static Map<String, dynamic> encode(RecommendationOptions options) {
    return {
      'id': options.id,
      'fillWithRandom': options.fillWithRandom,
      'size': options.size,
      'items': options.items,
      'noTrack': options.noTrack,
      'catalogAttributesWhitelist': options.catalogAttributesWhitelist,
    }..removeWhere((key, value) => value == null);
  }
}

abstract class RecommendationEncoder {
  static Recommendation decode(Map<String, dynamic> data) {
    return Recommendation(
      engineName: data['engineName'],
      itemId: data['itemId'],
      recommendationId: data['recommendationId'],
      recommendationVariantId: data['recommendationVariantId'],
      data: data['data'],
    );
  }

  static Map<String, dynamic> encode(Recommendation recommendation) {
    return {
      'engineName': recommendation.engineName,
      'itemId': recommendation.itemId,
      'recommendationId': recommendation.recommendationId,
      'recommendationVariantId': recommendation.recommendationVariantId,
      'data': recommendation.data,
    };
  }
}
