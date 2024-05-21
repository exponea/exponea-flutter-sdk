package com.exponea.widget

import android.content.Context
import android.util.Log
import com.exponea.getRequired
import com.exponea.sdk.Exponea
import com.exponea.sdk.models.InAppContentBlockPlaceholderConfiguration
import com.exponea.sdk.util.Logger
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.platform.PlatformView

class FlutterInAppContentBlockPlaceholderFactory(private val binding: FlutterPlugin.FlutterPluginBinding) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val creationParams = args as? Map<String?, Any?>
        val placeholderId =  creationParams?.get("placeholderId") as? String
        val overrideDefaultBehavior = creationParams?.get("overrideDefaultBehavior") as? Boolean
        if(placeholderId == null) {
            Logger.e(this, "InAppCB: Unable to parse placeholder identifier.".trimIndent())
        }
        if(overrideDefaultBehavior == null) {
            Logger.e(this, "InAppCB: Unable to parse overrideDefaultBehavior parameter.".trimIndent())
        }
        val inAppContentBlockPlaceholder = Exponea.getInAppContentBlocksPlaceholder(
            placeholderId ?: "",
            context!!,
            InAppContentBlockPlaceholderConfiguration(true)
        )

        return FlutterInAppContentBlockPlaceholder(
            context,
            viewId,
            placeholderId ?: "",
            inAppContentBlockPlaceholder,
            overrideDefaultBehavior ?: false,
            binding,
        )
    }
}


