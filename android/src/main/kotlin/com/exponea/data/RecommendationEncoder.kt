package com.exponea.data

import com.exponea.sdk.models.CustomerRecommendation

class RecommendationEncoder {
    companion object {
        fun encode(recommendation: CustomerRecommendation): Map<String, Any?> {
            return mapOf<String, Any?>(
                "engineName" to recommendation.engineName,
                "itemId" to recommendation.itemId,
                "recommendationId" to recommendation.recommendationId,
                "recommendationVariantId" to recommendation.recommendationVariantId,
                "data" to recommendation.data.mapValues { JsonElementEncoder.encode(it.value) }
            )
        }
    }
}