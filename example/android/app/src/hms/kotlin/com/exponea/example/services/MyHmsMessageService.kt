package com.exponea.example.services

import android.app.NotificationManager
import android.content.Context
import com.exponea.ExponeaPlugin
import com.huawei.hms.push.HmsMessageService
import com.huawei.hms.push.RemoteMessage

class MyHmsMessageService : HmsMessageService() {

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
