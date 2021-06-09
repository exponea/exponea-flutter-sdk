import 'package:meta/meta.dart';

@immutable
class RecommendationOptions {
  final String id;
  final bool fillWithRandom;
  final int? size;
  final Map<String, String>? items;
  final bool? noTrack;
  final List<String>? catalogAttributesWhitelist;

  const RecommendationOptions({
    required this.id,
    required this.fillWithRandom,
    this.size,
    this.items,
    this.noTrack,
    this.catalogAttributesWhitelist,
  });
}

@immutable
class Recommendation {
  final String engineName;
  final String itemId;
  final String recommendationId;
  final String recommendationVariantId;
  final Map<String, dynamic> data;

  const Recommendation({
    required this.engineName,
    required this.itemId,
    required this.recommendationId,
    required this.recommendationVariantId,
    required this.data,
  });
}
