package com.exponea.example

import com.exponea.sdk.models.ExponeaConfiguration.TokenFrequency
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class TokenFrequencyTest {
    companion object {
        lateinit var data: List<String>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readStringData("token_frequency")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 3)
    }

    @Test
    fun `encode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(TokenFrequency.values()[i].name, data[i])
        }
    }

    @Test
    fun `decode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(TokenFrequency.valueOf(data[i]), TokenFrequency.values()[i])
        }
    }
}
