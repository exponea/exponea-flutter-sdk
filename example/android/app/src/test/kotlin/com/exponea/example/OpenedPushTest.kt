package com.exponea.example

import com.exponea.data.OpenedPush
import com.exponea.data.PushAction
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class OpenedPushTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("push_opened")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `encode app action`() {
        val push = OpenedPush(action = PushAction.APP)
        val pushMap = push.toMap()
        assertEquals(pushMap, data[1])
    }

    @Test
    fun `encode deeplink action`() {
        val push = OpenedPush(
            action = PushAction.DEEPLINK,
            data = mapOf("test" to true, "num" to 1.23)
        )
        val pushMap = push.toMap()
        assertEquals(pushMap, data[2])
    }

    @Test
    fun `encode web action`() {
        val push = OpenedPush(
            action = PushAction.WEB,
            url = "https://a.b.c"
        )
        val pushMap = push.toMap()
        assertEquals(pushMap, data[3])
    }
}
