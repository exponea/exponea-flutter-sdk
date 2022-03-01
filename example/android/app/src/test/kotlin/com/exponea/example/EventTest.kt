package com.exponea.example

import com.exponea.data.Event
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class EventTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("event")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `parse empty map`() {
        try {
            Event.fromMap(data[0])
            fail("Should throw exception")
        } catch (e: Exception) {
            assertEquals("Event.name is required!", e.message)
        }
    }

    @Test
    fun `parse event with name only`() {
        val event = Event.fromMap(data[1])

        assertEquals(event.name, "test_event")
        assertEquals(event.properties.isEmpty(), true)
        assertEquals(event.timestamp, null)
    }

    @Test
    fun `parse event with empty values`() {
        val event = Event.fromMap(data[2])

        assertEquals(event.name, "test_event")
        assertEquals(event.properties.isEmpty(), true)
        assertEquals(event.timestamp, null)
    }

    @Test
    fun `parse full event`() {
        val event = Event.fromMap(data[3])

        assertEquals(event.name, "test_event")
        assertEquals(event.properties.size, 4)
        assertEquals(event.properties.get("str_test"), "abc-123")
        assertEquals(event.properties.get("double_test"), 123.987)
        assertEquals(event.properties.get("bool_test"), true)
        assertEquals(event.properties.get("int_test"), 109.0)
        assertEquals(event.timestamp, 1234567890.0)
    }
}
