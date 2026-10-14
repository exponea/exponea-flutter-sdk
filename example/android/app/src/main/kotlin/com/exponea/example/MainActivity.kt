package com.exponea.example

import android.content.Intent
import android.os.Bundle
import com.exponea.ExponeaPlugin
import com.exponea.example.logging.MemoryLogger
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var deeplinkChannel: MethodChannel? = null
    private var initialLink: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        ExponeaPlugin.handleCampaignIntent(intent, applicationContext)
        initialLink = intent?.dataString
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        ExponeaPlugin.handleCampaignIntent(intent, applicationContext)
        super.onNewIntent(intent)
        setIntent(intent)
        emitLink(intent.dataString)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MemoryLogger.start()
        SdkLogBridge.register(flutterEngine)
        deeplinkChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "exponea_example/deeplinks"
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialLink" -> result.success(initialLink)
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun emitLink(raw: String?) {
        if (raw.isNullOrBlank()) {
            return
        }
        deeplinkChannel?.invokeMethod("linkOpened", raw)
    }
}
