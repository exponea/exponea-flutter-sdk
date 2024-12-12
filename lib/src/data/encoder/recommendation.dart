import 'dart:convert';

import '../model/recommendation.dart';
import '../util/object.dart';

abstract class RecommendationOptionsEncoder {
  static RecommendationOptions decode(Map<String, dynamic> data) {
    return RecommendationOptions(
      id: data.getRequired('id'),
      fillWithRandom: data.getRequired('fillWithRandom'),
      size: data.getOptional('size'),
      items: data
          .getOptional<Map>('items')
          ?.map((k, v) => MapEntry(k.toString(), v.toString())),
      noTrack: data.getOptional('noTrack'),
      catalogAttributesWhitelist: data
          .getOptional<List>('catalogAttributesWhitelist')
          ?.map((it) => it.toString())
          .toList(growable: false),
    );
  }

  static Map<String, dynamic> encode(RecommendationOptions options) {
    return {
      'id': options.id,
      'fillWithRandom': options.fillWithRandom,
      'size': options.size?.toDouble(),
      'items': options.items,
      'noTrack': options.noTrack,
      'catalogAttributesWhitelist': options.catalogAttributesWhitelist,
    }..removeWhere((key, value) => value == null);
  }
}

abstract class RecommendationEncoder {
  static Recommendation decode(Map<dynamic, dynamic> data) {
    return Recommendation(
      engineName: data.getRequired('engineName'),
      itemId: data.getRequired('itemId'),
      recommendationId: data.getRequired('recommendationId'),
      recommendationVariantId: data.getOptional('recommendationVariantId'),
      data: jsonDecode(data
          .getRequired<String>('data'))
          .map<String, dynamic>((k, v) => MapEntry(k.toString(), v)),
    );
  }

  static Map<String, dynamic> encode(Recommendation recommendation) {
    return {
      'engineName': recommendation.engineName,
      'itemId': recommendation.itemId,
      'recommendationId': recommendation.recommendationId,
      'recommendationVariantId': recommendation.recommendationVariantId,
      'data': jsonEncode(recommendation.data),
    };
  }
}
