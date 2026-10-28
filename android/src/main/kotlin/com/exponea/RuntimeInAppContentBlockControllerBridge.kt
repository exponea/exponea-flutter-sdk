package com.exponea

import com.exponea.sdk.InAppContentBlockAvailability
import com.exponea.sdk.InAppContentBlockAvailabilityDecision
import com.exponea.sdk.InAppContentBlockInvalidateMode
import com.exponea.sdk.RuntimeInAppContentBlockController
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Locale

/**
 * Bridges the runtime in-app content block controller channel methods.
 *
 * The controller is resolved on every call through [controllerProvider], so
 * tests can pass a mock instead of the native [com.exponea.sdk.Exponea] object.
 * Error codes and messages match the React Native SDK.
 */
class RuntimeInAppContentBlockControllerBridge(
    private val controllerProvider: () -> RuntimeInAppContentBlockController?
) {
    companion object {
        private const val ERROR_UNAVAILABLE = "RuntimeInAppContentBlockControllerUnavailable"
        private const val ERROR_INVALID_MODE = "RuntimeInAppContentBlockControllerInvalidMode"
        private const val ERROR = "RuntimeInAppContentBlockControllerError"
    }

    fun prefetch(args: Any?, result: Result) = withController(result) { controller ->
        val data = args as Map<*, *>
        controller.prefetch(
            ids = data.ids(),
            deadlineMillis = (data["deadlineMs"] as Number?)?.toLong()
        ) { availabilities ->
            completeInCallback(result) {
                availabilities.mapValues { (_, availability) -> availability.toBridgeValue() }
            }
        }
    }

    fun availability(args: Any?, result: Result) = withController(result) { controller ->
        val data = args as Map<*, *>
        controller.availability(
            id = data["id"] as String,
            deadlineMillis = (data["deadlineMs"] as Number).toLong()
        ) { decision ->
            completeInCallback(result) {
                when (decision) {
                    is InAppContentBlockAvailabilityDecision.Resolved -> mapOf(
                        "status" to "resolved",
                        "availability" to decision.availability.toBridgeValue()
                    )
                    else -> mapOf("status" to "timedOut")
                }
            }
        }
    }

    fun invalidate(args: Any?, result: Result) = withController(result) { controller ->
        val data = args as Map<*, *>
        val mode = data["mode"] as String
        val nativeMode = when (mode.lowercase(Locale.ROOT)) {
            "eager" -> InAppContentBlockInvalidateMode.EAGER
            "lazy" -> InAppContentBlockInvalidateMode.LAZY
            else -> {
                result.error(ERROR_INVALID_MODE, "Unknown RuntimeInAppContentBlockController invalidate mode: $mode", null)
                return@withController
            }
        }
        // Completes once the request is accepted, as on iOS; the native completion callback is not used.
        controller.invalidate(data.ids(), data["reason"] as String, nativeMode, null)
        result.success(null)
    }

    private inline fun withController(result: Result, block: (RuntimeInAppContentBlockController) -> Unit) {
        try {
            val controller = controllerProvider()
            if (controller == null) {
                result.error(
                    ERROR_UNAVAILABLE,
                    "RuntimeInAppContentBlockController is unavailable because the Exponea SDK is not configured.",
                    null
                )
                return
            }
            block(controller)
        } catch (e: Exception) {
            result.error(ERROR, e.message, e.javaClass.name)
        }
    }

    // Native callbacks run later on the main thread, outside the try/catch in withController.
    // A failure there must reject the call instead of crashing the app.
    private inline fun completeInCallback(result: Result, buildResult: () -> Any?) {
        try {
            result.success(buildResult())
        } catch (e: Exception) {
            result.error(ERROR, e.message, e.javaClass.name)
        }
    }

    private fun Map<*, *>.ids(): List<String> = (this["ids"] as List<*>).map { it as String }

    private fun InAppContentBlockAvailability.toBridgeValue(): String = when (this) {
        InAppContentBlockAvailability.Ready -> "ready"
        InAppContentBlockAvailability.Empty -> "empty"
        else -> "loading"
    }
}
