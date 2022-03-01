package com.exponea.example

import com.exponea.data.ConsentEncoder
import com.exponea.sdk.models.Consent
import com.exponea.sdk.models.ConsentSources
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class ConsentTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass
        @JvmStatic
        fun setup() {
            data = BaseTest.readMapData("consent")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `encode min`() {
        val consent = Consent(
            id = "mock-id",
            legitimateInterest = true,
            sources = ConsentSources(
                createdFromCRM = false,
                imported = true,
                fromConsentPage = false,
                privateAPI = true,
                publicAPI = false,
                trackedFromScenario = true
            ),
            translations = hashMapOf()
        )
        val encoded = ConsentEncoder.encode(consent)

        assertEquals(encoded, data[2])
    }

    @Test
    fun `encode full`() {
        val consent = Consent(
            id = "mock-id",
            legitimateInterest = true,
            sources = ConsentSources(
                createdFromCRM = false,
                imported = true,
                fromConsentPage = false,
                privateAPI = true,
                publicAPI = false,
                trackedFromScenario = true
            ),
            translations = hashMapOf(
                "cz" to hashMapOf(
                    "test" to "aaaa",
                    "desc" to ""
                )
            )
        )
        val encoded = ConsentEncoder.encode(consent)

        assertEquals(encoded, data[3])
    }
}
