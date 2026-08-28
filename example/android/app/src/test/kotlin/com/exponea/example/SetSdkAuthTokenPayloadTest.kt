package com.exponea.example

import org.junit.Assert.assertEquals
import org.junit.BeforeClass
import org.junit.Test

class SetSdkAuthTokenPayloadTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("set_sdk_auth_token_payload")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 1)
    }

    @Test
    fun `parse token payload`() {
        assertEquals(data[0]["token"], "mock-jwt-token")
    }
}
