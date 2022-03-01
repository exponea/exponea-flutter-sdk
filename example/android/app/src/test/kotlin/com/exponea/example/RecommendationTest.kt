package com.exponea.example

import com.exponea.data.RecommendationEncoder
import com.exponea.sdk.models.CustomerRecommendation
import com.google.gson.JsonPrimitive
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class RecommendationTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass
        @JvmStatic
        fun setup() {
            data = BaseTest.readMapData("recommendation")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `encode min`() {
        val recommendation = CustomerRecommendation(
            engineName = "mock-engine",
            itemId = "mock-item",
            recommendationId = "mock-rec-id",
            recommendationVariantId = "mock-variant-id",
            data = mapOf()
        )
        val encoded = RecommendationEncoder.encode(recommendation)

        assertEquals(BaseTest.toJson(encoded), BaseTest.toJson(data[2]))
    }

    @Test
    fun `encode full`() {
        val recommendation = CustomerRecommendation(
            engineName = "mock-engine",
            itemId = "mock-item",
            recommendationId = "mock-rec-id",
            recommendationVariantId = "mock-variant-id",
            data = mapOf("a" to JsonPrimitive(123.0), "b" to JsonPrimitive(true))
        )
        val encoded = RecommendationEncoder.encode(recommendation)

        assertEquals(BaseTest.toJson(encoded), BaseTest.toJson(data[3]))
    }
}
