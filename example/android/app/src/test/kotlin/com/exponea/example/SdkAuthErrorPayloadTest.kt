package com.exponea.example

import org.junit.Assert.assertEquals
import org.junit.BeforeClass
import org.junit.Test

class SdkAuthErrorPayloadTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("sdk_auth_error")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 5)
    }

    @Test
    fun `parse token about to expire payload`() {
        assertEquals(data[0]["errorCode"], "TOKEN_ABOUT_TO_EXPIRE")
        @Suppress("UNCHECKED_CAST")
        val ids = data[0]["customerIds"] as Map<String, String>
        assertEquals(ids["registered"], "user@example.com")
    }

    @Test
    fun `parse token insufficient payload`() {
        assertEquals(data[4]["errorCode"], "TOKEN_INSUFFICIENT")
    }
}
