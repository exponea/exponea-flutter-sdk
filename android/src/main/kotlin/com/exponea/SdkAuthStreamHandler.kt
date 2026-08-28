package com.exponea

import android.os.Handler
import android.os.Looper
import androidx.annotation.VisibleForTesting
import com.exponea.data.SdkAuthError
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler

/**
 * Handles listeners for SDK JWT auth errors (Stream / Data Hub).
 */
class SdkAuthStreamHandler : StreamHandler {
    companion object {
        private var currentInstance: SdkAuthStreamHandler? = null

        private var pendingData: SdkAuthError? = null

        /**
         * Marshals delivery onto the main thread.
         *
         * The native SDK invokes the [com.exponea.sdk.models.SdkAuthCallback] from an OkHttp
         * network thread, but Flutter's [EventSink] methods are annotated `@UiThread` and the
         * Android embedding enforces this at runtime. Posting to the main looper prevents the
         * `RuntimeException: Methods marked with @UiThread must be executed on the main thread`
         * that otherwise breaks the auth-error -> token-refresh flow.
         *
         * Overridable in tests to deliver synchronously.
         */
        @VisibleForTesting
        var mainThreadDispatcher: (Runnable) -> Unit = { runnable ->
            Handler(Looper.getMainLooper()).post(runnable)
        }

        fun handle(error: SdkAuthError): Boolean {
            val handled = currentInstance?.internalHandle(error) ?: false
            if (!handled) {
                pendingData = error
            }
            return handled
        }

        @VisibleForTesting
        fun resetForTesting() {
            currentInstance = null
            pendingData = null
            mainThreadDispatcher = { runnable ->
                Handler(Looper.getMainLooper()).post(runnable)
            }
        }
    }

    init {
        currentInstance = this
    }

    private var eventSink: EventSink? = null

    override fun onListen(arguments: Any?, eSink: EventSink?) {
        eventSink = eSink
        pendingData?.let {
            if (handle(it)) {
                pendingData = null
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun internalHandle(error: SdkAuthError): Boolean {
        val sink = eventSink ?: return false
        mainThreadDispatcher.invoke { sink.success(error.toMap()) }
        return true
    }
}
