package com.exponea.example

import com.exponea.RuntimeInAppContentBlockControllerBridge
import com.exponea.sdk.InAppContentBlockAvailability
import com.exponea.sdk.InAppContentBlockAvailabilityDecision
import com.exponea.sdk.InAppContentBlockInvalidateMode
import com.exponea.sdk.RuntimeInAppContentBlockController
import io.flutter.plugin.common.MethodChannel
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

private typealias PrefetchCallback = (Map<String, InAppContentBlockAvailability>) -> Unit
private typealias AvailabilityCallback = (InAppContentBlockAvailabilityDecision) -> Unit

class RuntimeInAppContentBlockControllerBridgeTest {
    private class RecordingResult(
        private val throwOnSuccess: Boolean = false,
    ) : MethodChannel.Result {
        val successes = mutableListOf<Any?>()
        val errors = mutableListOf<Triple<String, String?, Any?>>()
        var notImplementedCalls = 0

        val calls: Int get() = successes.size + errors.size + notImplementedCalls

        override fun success(result: Any?) {
            if (throwOnSuccess) throw IllegalStateException("success failed")
            successes.add(result)
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            errors.add(Triple(errorCode, errorMessage, errorDetails))
        }

        override fun notImplemented() {
            notImplementedCalls++
        }
    }

    private lateinit var controller: RuntimeInAppContentBlockController
    private lateinit var bridge: RuntimeInAppContentBlockControllerBridge

    @Before
    fun setUp() {
        controller = mockk(relaxed = true)
        bridge = RuntimeInAppContentBlockControllerBridge { controller }
    }

    @Test
    fun `rejects every call with Unavailable when the native controller is null`() {
        val unavailable = RuntimeInAppContentBlockControllerBridge { null }
        val results = listOf(RecordingResult(), RecordingResult(), RecordingResult())

        unavailable.prefetch(mapOf("ids" to listOf("a"), "deadlineMs" to 1), results[0])
        unavailable.availability(mapOf("id" to "a", "deadlineMs" to 1), results[1])
        unavailable.invalidate(mapOf("ids" to listOf("a"), "reason" to "x", "mode" to "eager"), results[2])

        results.forEach { result ->
            assertEquals(1, result.calls)
            assertEquals("RuntimeInAppContentBlockControllerUnavailable", result.errors.single().first)
            assertEquals(
                "RuntimeInAppContentBlockController is unavailable because the Exponea SDK is not configured.",
                result.errors.single().second
            )
        }
    }

    @Test
    fun `prefetch forwards ids and deadline and maps the result`() {
        val callback = slot<PrefetchCallback>()
        every { controller.prefetch(listOf("a", "b", "c"), 2000L, capture(callback)) } answers {
            callback.captured(
                mapOf(
                    "a" to InAppContentBlockAvailability.Ready,
                    "b" to InAppContentBlockAvailability.Empty,
                    "c" to InAppContentBlockAvailability.Loading,
                )
            )
        }
        val result = RecordingResult()

        bridge.prefetch(mapOf("ids" to listOf("a", "b", "c"), "deadlineMs" to 2000), result)

        assertEquals(1, result.calls)
        assertEquals(mapOf("a" to "ready", "b" to "empty", "c" to "loading"), result.successes.single())
    }

    @Test
    fun `prefetch accepts a Long deadline and a missing deadline`() {
        val result = RecordingResult()

        bridge.prefetch(mapOf("ids" to listOf("a"), "deadlineMs" to 5_000_000_000L), result)
        bridge.prefetch(mapOf("ids" to listOf("a"), "deadlineMs" to null), result)

        verify { controller.prefetch(listOf("a"), 5_000_000_000L, any()) }
        verify { controller.prefetch(listOf("a"), null, any()) }
    }

    @Test
    fun `zero and negative deadlines reach native unchanged`() {
        bridge.prefetch(mapOf("ids" to listOf("a"), "deadlineMs" to 0), RecordingResult())
        bridge.availability(mapOf("id" to "a", "deadlineMs" to -5), RecordingResult())

        verify { controller.prefetch(listOf("a"), 0L, any()) }
        verify { controller.availability("a", -5L, any()) }
    }

    @Test
    fun `availability maps resolved and timed out decisions`() {
        val callback = slot<AvailabilityCallback>()
        every { controller.availability("a", 2000L, capture(callback)) } answers {
            callback.captured(InAppContentBlockAvailabilityDecision.Resolved(InAppContentBlockAvailability.Ready))
        }
        every { controller.availability("b", 2000L, capture(callback)) } answers {
            callback.captured(InAppContentBlockAvailabilityDecision.TimedOut)
        }
        val resolved = RecordingResult()
        val timedOut = RecordingResult()

        bridge.availability(mapOf("id" to "a", "deadlineMs" to 2000), resolved)
        bridge.availability(mapOf("id" to "b", "deadlineMs" to 2000), timedOut)

        assertEquals(mapOf("status" to "resolved", "availability" to "ready"), resolved.successes.single())
        assertEquals(mapOf("status" to "timedOut"), timedOut.successes.single())
    }

    @Test
    fun `invalidate completes immediately without using the native callback`() {
        val result = RecordingResult()

        bridge.invalidate(mapOf("ids" to listOf("a"), "reason" to "x", "mode" to "eager"), result)

        verify { controller.invalidate(listOf("a"), "x", InAppContentBlockInvalidateMode.EAGER, null) }
        assertEquals(1, result.calls)
        assertNull(result.successes.single())
    }

    @Test
    fun `invalidate matches the mode case-insensitively`() {
        bridge.invalidate(mapOf("ids" to listOf("a"), "reason" to "x", "mode" to "EAGER"), RecordingResult())
        bridge.invalidate(mapOf("ids" to listOf("b"), "reason" to "y", "mode" to "Lazy"), RecordingResult())

        verify { controller.invalidate(listOf("a"), "x", InAppContentBlockInvalidateMode.EAGER, null) }
        verify { controller.invalidate(listOf("b"), "y", InAppContentBlockInvalidateMode.LAZY, null) }
    }

    @Test
    fun `invalidate rejects an unknown mode with InvalidMode`() {
        val result = RecordingResult()

        bridge.invalidate(mapOf("ids" to listOf("a"), "reason" to "x", "mode" to "bogus"), result)

        assertEquals(1, result.calls)
        assertEquals("RuntimeInAppContentBlockControllerInvalidMode", result.errors.single().first)
        assertEquals("Unknown RuntimeInAppContentBlockController invalidate mode: bogus", result.errors.single().second)
        verify(exactly = 0) { controller.invalidate(any(), any(), any(), any()) }
    }

    @Test
    fun `a synchronous native failure is rejected with Error and keeps the message`() {
        every { controller.prefetch(any(), any(), any()) } throws IllegalStateException("native boom")
        val result = RecordingResult()

        bridge.prefetch(mapOf("ids" to listOf("a"), "deadlineMs" to 1), result)

        assertEquals(1, result.calls)
        assertEquals("RuntimeInAppContentBlockControllerError", result.errors.single().first)
        assertEquals("native boom", result.errors.single().second)
    }

    @Test
    fun `invalid arguments are rejected with Error`() {
        val result = RecordingResult()

        bridge.prefetch(mapOf("deadlineMs" to 1), result)

        assertEquals(1, result.calls)
        assertEquals("RuntimeInAppContentBlockControllerError", result.errors.single().first)
    }

    @Test
    fun `an exception inside the native callback is rejected with Error instead of crashing`() {
        val prefetchCallback = slot<PrefetchCallback>()
        val availabilityCallback = slot<AvailabilityCallback>()
        every { controller.prefetch(any(), any(), capture(prefetchCallback)) } returns Unit
        every { controller.availability(any(), any(), capture(availabilityCallback)) } returns Unit
        val prefetchResult = RecordingResult(throwOnSuccess = true)
        val availabilityResult = RecordingResult(throwOnSuccess = true)

        bridge.prefetch(mapOf("ids" to listOf("a"), "deadlineMs" to 1), prefetchResult)
        bridge.availability(mapOf("id" to "a", "deadlineMs" to 1), availabilityResult)
        // The native SDK invokes the callbacks later, outside the synchronous call.
        prefetchCallback.captured(mapOf("a" to InAppContentBlockAvailability.Ready))
        availabilityCallback.captured(InAppContentBlockAvailabilityDecision.TimedOut)

        listOf(prefetchResult, availabilityResult).forEach { result ->
            assertEquals("RuntimeInAppContentBlockControllerError", result.errors.single().first)
            assertEquals("success failed", result.errors.single().second)
            assertTrue(result.successes.isEmpty())
        }
    }
}
