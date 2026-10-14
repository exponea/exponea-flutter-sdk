package com.exponea.example

import android.app.NotificationManager
import android.content.Context
import com.exponea.ExponeaPlugin
import com.huawei.hms.push.HmsMessageService
import com.huawei.hms.push.RemoteMessage

/**
 * Forwards HMS Push Kit token refreshes and incoming messages to the Exponea SDK in the `hms`
 * flavor, like the legacy example's `MyHmsMessageService`.
 */
class ExampleHmsMessagingService : HmsMessageService() {

    private val notificationManager by lazy {
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        ExponeaPlugin.handleRemoteMessage(applicationContext, message.dataOfMap, notificationManager)
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        ExponeaPlugin.handleNewHmsToken(applicationContext, token)
    }
}
