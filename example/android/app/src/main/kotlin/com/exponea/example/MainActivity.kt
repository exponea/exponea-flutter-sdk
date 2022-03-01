package com.exponea.example

import android.content.Intent
import android.os.Bundle
import com.exponea.ExponeaPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        ExponeaPlugin.handleCampaignIntent(intent, applicationContext)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        ExponeaPlugin.handleCampaignIntent(intent, applicationContext)
        super.onNewIntent(intent)
    }
}
