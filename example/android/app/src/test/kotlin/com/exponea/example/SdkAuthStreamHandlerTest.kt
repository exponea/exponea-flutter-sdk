package com.exponea.example

import com.exponea.SdkAuthStreamHandler
import com.exponea.data.SdkAuthError
import io.flutter.plugin.common.EventChannel
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class SdkAuthStreamHandlerTest {
    private class FakeEventSink : EventChannel.EventSink {
        val events = mutableListOf<Any>()

        override fun success(eventData: Any?) {
            events.add(eventData!!)
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}

        override fun endOfStream() {}
    }

    @Before
    fun setUp() {
        SdkAuthStreamHandler.resetForTesting()
        // Deliver synchronously so we avoid touching the Android main Looper in unit tests.
        SdkAuthStreamHandler.mainThreadDispatcher = { it.run() }
    }

    @After
    fun tearDown() {
        SdkAuthStreamHandler.resetForTesting()
    }

    @Test
    fun `delivers pending auth error when listener attaches`() {
        val error = SdkAuthError(
            errorCode = "TOKEN_EXPIRED",
            customerIds = mapOf("registered" to "user@example.com"),
        )
        SdkAuthStreamHandler.handle(error)

        val handler = SdkAuthStreamHandler()
        val sink = FakeEventSink()
        handler.onListen(null, sink)

        assertEquals(1, sink.events.size)
        @Suppress("UNCHECKED_CAST")
        val payload = sink.events[0] as Map<String, Any?>
        assertEquals("TOKEN_EXPIRED", payload["errorCode"])
        assertTrue((payload["customerIds"] as Map<*, *>)["registered"] == "user@example.com")
    }

    @Test
    fun `delivers auth error through main thread dispatcher`() {
        // Simulates the native SDK invoking the callback from an OkHttp network thread:
        // delivery to the Flutter EventSink must be routed via the main-thread dispatcher.
        var dispatched = false
        SdkAuthStreamHandler.mainThreadDispatcher = { runnable ->
            dispatched = true
            runnable.run()
        }

        val handler = SdkAuthStreamHandler()
        val sink = FakeEventSink()
        handler.onListen(null, sink)

        val error = SdkAuthError(
            errorCode = "TOKEN_EXPIRED",
            customerIds = mapOf("registered" to "user@example.com"),
        )
        val handled = SdkAuthStreamHandler.handle(error)

        assertTrue(handled)
        assertTrue(dispatched)
        assertEquals(1, sink.events.size)
    }
}
