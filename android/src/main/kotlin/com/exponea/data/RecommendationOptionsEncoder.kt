package com.exponea.data

import com.exponea.sdk.models.CustomerRecommendationOptions

class RecommendationOptionsEncoder {
    companion object {
        fun decode(data: Map<String, Any?>): CustomerRecommendationOptions {
            return CustomerRecommendationOptions(
                id = data.getRequired("id"),
                fillWithRandom = data.getRequired("fillWithRandom"),
                size = data.getOptional<Double>("size")?.toInt() ?: 10,
                items = data.getOptional("items"),
                noTrack = data.getOptional("noTrack"),
                catalogAttributesWhitelist = data.getOptional("catalogAttributesWhitelist")
            )
        }
    }
}