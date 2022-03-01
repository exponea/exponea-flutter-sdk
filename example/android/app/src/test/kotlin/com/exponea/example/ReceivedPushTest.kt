package com.exponea.example

import com.exponea.data.ReceivedPush
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class ReceivedPushTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("push_received")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `encode empty data`() {
        val push = ReceivedPush(data = mapOf())
        val pushMap = push.toMap()
        assertEquals(pushMap, data[2])
    }

    @Test
    fun `encode with data`() {
        val push = ReceivedPush(data = mapOf("test" to true, "num" to 1.23))
        val pushMap = push.toMap()
        assertEquals(pushMap, data[3])
    }
}
