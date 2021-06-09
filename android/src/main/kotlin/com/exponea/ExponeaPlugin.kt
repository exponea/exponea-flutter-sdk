package com.exponea

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.exponea.exception.ExponeaException
import com.exponea.sdk.Exponea
import com.exponea.sdk.models.ExponeaConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception

private const val TAG = "ExponeaPlugin"

/**
 * Exponea Android Plugin
 */
class ExponeaPlugin : FlutterPlugin {
    companion object {
        private const val CHANNEL_NAME = "com.exponea"
    }

    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).apply {
            val methodHandler = ExponeaMethodHandler(context)
            setMethodCallHandler(methodHandler)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}

@Suppress("UNCHECKED_CAST")
private class ExponeaMethodHandler(private val context: Context) : MethodCallHandler {
    companion object {
        private const val METHOD_CONFIGURE = "configure"
        private const val METHOD_IS_CONFIGURED = "isConfigured"
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.i(TAG, "onMethodCall(${call.method})")

        when (call.method) {
            METHOD_CONFIGURE -> {
                val data = call.arguments as Map<String, Any?>
                configure(data, result)
            }
            METHOD_IS_CONFIGURED -> {
                isConfigured(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun requireInitialized(result: Result, block: ((Result) -> Unit)) {
        if (!Exponea.isInitialized) {
            result.error("1", "Exponea SDK is not configured. Call configure() before calling functions of the SDK", null)
        } else {
            block.invoke(result)
        }
    }

    private fun catchAndReject(result: Result, block: () -> Unit) {
        try {
            block()
        } catch (e: Exception) {
            result.error("2", e.message, null)
        }
    }

    private fun configure(data: Map<String, Any?>, result: Result) = catchAndReject(result) {
        if (Exponea.isInitialized) {
            throw ExponeaException.alreadyConfigured()
        }

        val configuration = ExponeaConfigurationParser().parse(data)
        Exponea.init(context, configuration)
        // FIXME Exponea.notificationDataCallback = { pushNotificationReceived(it) }
        result.success(null)
    }

    private fun isConfigured(result: Result) = catchAndReject(result) {
        result.success(Exponea.isInitialized)
    }
}
