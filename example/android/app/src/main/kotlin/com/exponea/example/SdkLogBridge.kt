package com.exponea.example

import android.os.Handler
import android.os.Looper
import com.exponea.example.logging.MemoryLogger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

object SdkLogBridge {
    private const val EVENT_CHANNEL = "exponea_example/sdk_logs"
    private const val CONTROL_CHANNEL = "exponea_example/sdk_logs_control"

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    fun register(flutterEngine: FlutterEngine) {
        MemoryLogger.setListener { entry ->
            mainHandler.post { eventSink?.success(entry.toWireMap()) }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    MemoryLogger.snapshot().forEach { events?.success(it.toWireMap()) }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTROL_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "clear" -> {
                        MemoryLogger.clear()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
