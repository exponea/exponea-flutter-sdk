package com.exponea.example

import com.exponea.sdk.models.EventType
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class EventTypeTest {
    companion object {
        lateinit var data: List<String>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readStringData("event_type")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 11)
    }

    @Test
    fun `encode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(EventType.values()[i].name, data[i])
        }
    }

    @Test
    fun `decode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(EventType.valueOf(data[i]), EventType.values()[i])
        }
    }
}
