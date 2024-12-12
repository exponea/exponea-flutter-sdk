package com.exponea.data

import com.exponea.sdk.models.CustomerRecommendation
import com.exponea.sdk.util.ExponeaGson

class RecommendationEncoder {
    companion object {
        fun encode(recommendation: CustomerRecommendation): Map<String, Any?> {
            return mapOf<String, Any?>(
                "engineName" to recommendation.engineName,
                "itemId" to recommendation.itemId,
                "recommendationId" to recommendation.recommendationId,
                "recommendationVariantId" to recommendation.recommendationVariantId,
                "data" to ExponeaGson.instance.toJson(recommendation.data)
            )
        }
    }
}