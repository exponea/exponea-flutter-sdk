package com.exponea.example

import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.exponea.ExponeaPlugin
import io.flutter.embedding.android.FlutterActivity

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
}
