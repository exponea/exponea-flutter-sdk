package com.exponea.widget

import android.content.Context
import android.util.Log
import android.view.View
import com.exponea.sdk.Exponea
import com.exponea.sdk.util.Logger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterAppInboxDetailView(
    private val context: Context,
    id: Int,
    private val messageId: String,
) : PlatformView {

    private val appInboxDetailView: View?

    class Factory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
            val messageId = (args as? Map<*, *>)?.get("messageId") as? String ?: {
                Logger.e(this, "Unable to parse message identifier.")
                ""
            }.toString()
            return FlutterAppInboxDetailView(context!!, viewId, messageId = messageId)
        }
    }

    init {
        appInboxDetailView = Exponea.getAppInboxDetailView(context = context, messageId = messageId)
    }

    override fun getView(): View? {
        return appInboxDetailView
    }

    override fun dispose() {

    }
}