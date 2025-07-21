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
    final rawData = jsonDecode(data.getRequired<String>('data'));
    final normalizedData = _normalizeDataTypes(rawData);
    
    return Recommendation(
      engineName: data.getRequired('engineName'),
      itemId: data.getRequired('itemId'),
      recommendationId: data.getRequired('recommendationId'),
      recommendationVariantId: data.getOptional('recommendationVariantId'),
      data: normalizedData.map<String, dynamic>((k, v) => MapEntry(k.toString(), v)),
    );
  }

  /// Normalizes data types to ensure consistent field types
  /// Fields like sku_id, product_code, and available are converted to Strings
  static Map<String, dynamic> _normalizeDataTypes(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // List of fields that should always be strings
      const stringFields = [
        'sku_id',
        'product_code',
        'product_id',
        'item_id',
        'available',
        // Add more fields here if needed
      ];
      
      if (stringFields.contains(key) && value != null) {
        // Convert to string if it's one of the specified fields
        normalized[key] = value.toString();
      } else {
        // Keep original value for other fields
        normalized[key] = value;
      }
    }
    
    return normalized;
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
