package com.exponea.example

import com.exponea.data.RecommendationOptionsEncoder
import com.exponea.sdk.models.CustomerRecommendationOptions
import com.google.gson.JsonPrimitive
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class RecommendationOptionsTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass
        @JvmStatic
        fun setup() {
            data = BaseTest.readMapData("recommendation_options")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `decode empty map`() {
        try {
            RecommendationOptionsEncoder.decode(data[0])
            fail("Should throw exception")
        } catch (e: Exception) {
            assertEquals("Property id is required.", e.message)
        }
    }

    @Test
    fun `decode missing fillWithRandom`() {
        try {
            RecommendationOptionsEncoder.decode(data[1])
            fail("Should throw exception")
        } catch (e: Exception) {
            assertEquals("Property fillWithRandom is required.", e.message)
        }
    }

    @Test
    fun `decode min`() {
        val expected = CustomerRecommendationOptions(
            id = "mock-id",
            fillWithRandom = true
        )
        val decoded = RecommendationOptionsEncoder.decode(data[2])

        assertEquals(decoded.id, expected.id)
        assertEquals(decoded.fillWithRandom, expected.fillWithRandom)
        assertEquals(decoded.size, expected.size)
        assertEquals(decoded.items, expected.items)
        assertEquals(decoded.noTrack, expected.noTrack)
        assertEquals(decoded.catalogAttributesWhitelist, expected.catalogAttributesWhitelist)
    }

    @Test
    fun `decode full`() {
        val expected = CustomerRecommendationOptions(
            id = "mock-id",
            fillWithRandom = false,
            size = 5,
            items = mapOf("a" to "b", "c" to "d"),
            noTrack = true,
            catalogAttributesWhitelist = listOf("1", "test", "...mock")
        )
        val decoded = RecommendationOptionsEncoder.decode(data[3])

        assertEquals(decoded.id, expected.id)
        assertEquals(decoded.fillWithRandom, expected.fillWithRandom)
        assertEquals(decoded.size, expected.size)
        assertEquals(decoded.items, expected.items)
        assertEquals(decoded.noTrack, expected.noTrack)
        assertEquals(decoded.catalogAttributesWhitelist, expected.catalogAttributesWhitelist)
    }
}
