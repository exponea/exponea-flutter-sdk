package com.exponea

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.exponea.data.OpenedPush
import com.exponea.data.PushAction
import com.exponea.sdk.ExponeaExtras
import com.exponea.sdk.models.NotificationAction
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class ExponeaPushReceiver : BroadcastReceiver() {
    /**
     * We respond to all push notification actions and pass the push notification information to ExponeaPlugin.
     * For default "open app" action, we also start the application.
     * For "deeplink" action, Exponea SDK will generate intent and it's up to the developer to implement Intent handler.
     * For "web" action, Exponea SDK will generate intent that will be handled by the browser.
     */
    override fun onReceive(context: Context, intent: Intent) {
        val action = when (intent.action) {
            ExponeaExtras.ACTION_CLICKED -> PushAction.APP
            ExponeaExtras.ACTION_DEEPLINK_CLICKED -> PushAction.DEEPLINK
            ExponeaExtras.ACTION_URL_CLICKED -> PushAction.WEB
            else -> throw RuntimeException("Unknown push notification action ${intent.action}")
        }

        val actionInfo = intent.getSerializableExtra(ExponeaExtras.EXTRA_ACTION_INFO) as? NotificationAction
        val url = actionInfo?.url
        val pushData = intent.getSerializableExtra(ExponeaExtras.EXTRA_CUSTOM_DATA) as? Map<String, String>
        val additionalData = pushData?.let {
            val additionalDataType = object : TypeToken<Map<String, Any?>?>() {}.getType()
            Gson().fromJson(it["attributes"], additionalDataType) as? Map<String, Any?>
        }
        OpenedPushStreamHandler.handle(OpenedPush(action, url, additionalData))
    }
}
