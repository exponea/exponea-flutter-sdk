package com.exponea.widget

import android.content.Context
import android.util.Log
import android.view.View
import com.exponea.data.AppInboxCoder
import com.exponea.sdk.Exponea
import com.exponea.sdk.models.MessageItem
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterAppInboxListView(
    private val context: Context,
    id: Int,
    private val binding: FlutterPlugin.FlutterPluginBinding,
) : PlatformView {

    private val CHANNEL_NAME = "com.exponea/AppInboxListView"
    private val METHOD_ON_APP_INBOX_ITEM_CLICKED = "onAppInboxItemClicked"
    private var channel: MethodChannel? = null
    private val appInboxListView: View?

    class Factory(private val binding: FlutterPlugin.FlutterPluginBinding) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
            return FlutterAppInboxListView(context!!, viewId, binding)
        }
    }

    init {
        channel = MethodChannel(binding.binaryMessenger, "$CHANNEL_NAME/$id")
        appInboxListView = Exponea.getAppInboxListView(context = context, onItemClicked = ::onItemClicked)
    }

    private fun onItemClicked(messageItem : MessageItem, index : Int) {
        CoroutineScope(Dispatchers.Main).launch {
            channel?.invokeMethod(
                METHOD_ON_APP_INBOX_ITEM_CLICKED,
                AppInboxCoder.encode(messageItem)
            )
        }
    }

    override fun getView(): View? {
        return appInboxListView
    }

    override fun dispose() {
        channel = null
    }
}