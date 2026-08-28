package com.exponea.example

import com.exponea.data.CustomerIdentityParser
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.BeforeClass
import org.junit.Test

class CustomerIdentityParserTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("configure_payload")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(4, data.size)
    }

    @Test
    fun `parse null customer identity`() {
        assertNull(CustomerIdentityParser.parse(null))
    }

    @Test
    fun `parse configure payload without customer identity`() {
        assertNull(CustomerIdentityParser.parse(data[0]["customerIdentity"] as? Map<String, Any?>))
    }

    @Test
    fun `parse customer identity with jwt`() {
        val identity = CustomerIdentityParser.parse(data[1]["customerIdentity"] as Map<String, Any?>)

        assertEquals(identity?.customerIds, mapOf("registered" to "test@mail.com"))
        assertEquals(identity?.sdkAuthToken, "mock-jwt-token")
    }

    @Test
    fun `parse customer identity without jwt`() {
        val identity = CustomerIdentityParser.parse(data[2]["customerIdentity"] as Map<String, Any?>)

        assertEquals(identity?.customerIds, mapOf("registered" to "test@mail.com"))
        assertNull(identity?.sdkAuthToken)
    }

    @Test
    fun `parse customer identity with jwt and regenerateDeviceIdOnAnonymize payload`() {
        val identity = CustomerIdentityParser.parse(data[3]["customerIdentity"] as Map<String, Any?>)

        assertEquals(identity?.customerIds, mapOf("registered" to "test@mail.com"))
        assertEquals(identity?.sdkAuthToken, "mock-jwt-token")
        assertEquals(data[3]["regenerateDeviceIdOnAnonymize"], true)
    }
}

class IdentifyCustomerParserTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("identify_customer_payload")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 5)
    }

    @Test
    fun `parse legacy customer payload`() {
        val customer = com.exponea.data.Customer.fromMap(data[1])

        assertEquals(customer.ids["registered"], "test@mail.com")
        assertEquals(customer.properties["str_test"], "abc-123")
    }

    @Test
    fun `parse customer identity with jwt and properties`() {
        val payload = data[4]
        val identity = CustomerIdentityParser.parse(payload)

        assertEquals(identity?.customerIds, mapOf("registered" to "test@mail.com"))
        assertEquals(identity?.sdkAuthToken, "mock-jwt-token")
        assertEquals((payload["properties"] as Map<*, *>)["first_name"], "Alice")
    }
}
