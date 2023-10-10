package com.exponea.example

import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.exponea.ExponeaPlugin
import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        var APP_CONTEXT: Context? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Potential MemoryLeak but still fine
        APP_CONTEXT = applicationContext
        ExponeaPlugin.handleCampaignIntent(intent, applicationContext)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        ExponeaPlugin.handleCampaignIntent(intent, applicationContext)
        super.onNewIntent(intent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.exponea.example/utils").setMethodCallHandler { call, result ->
            if (call.method == "getAndroidPushIcon") {
                result.success(R.mipmap.ic_notification)
            } else {
                result.notImplemented()
            }
        }
    }
}
