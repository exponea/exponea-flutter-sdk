package com.exponea.example

import com.exponea.data.Customer
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class CustomerTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("customer")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `parse empty map`() {
        val customer = Customer.fromMap(data[0])

        assertEquals(customer.ids.isEmpty(), true)
        assertEquals(customer.properties.isEmpty(), true)
    }

    @Test
    fun `parse empty customer`() {
        val customer = Customer.fromMap(data[1])

        assertEquals(customer.ids.isEmpty(), true)
        assertEquals(customer.properties.isEmpty(), true)
    }

    @Test
    fun `parse customer with registered email`() {
        val customer = Customer.fromMap(data[2])

        assertEquals(customer.ids.size, 1)
        assertEquals(customer.ids.get("registered"), "test@mail.com")
        assertEquals(customer.properties.isEmpty(), true)
    }

    @Test
    fun `parse customer with everything`() {
        val customer = Customer.fromMap(data[3])

        assertEquals(customer.ids.size, 1)
        assertEquals(customer.ids.get("registered"), "test@mail.com")
        assertEquals(customer.properties.size, 4)
        assertEquals(customer.properties.get("str_test"), "abc-123")
        assertEquals(customer.properties.get("double_test"), 123.987)
        assertEquals(customer.properties.get("bool_test"), true)
        assertEquals(customer.properties.get("int_test"), 109.0)
    }
}
