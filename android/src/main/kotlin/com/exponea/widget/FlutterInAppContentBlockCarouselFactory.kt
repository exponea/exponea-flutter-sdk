package com.exponea.widget

import android.content.Context
import com.exponea.widget.getRequired
import com.exponea.widget.getOptional
import com.exponea.sdk.Exponea
import com.exponea.sdk.util.Logger
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.platform.PlatformView

class FlutterInAppContentBlockCarouselFactory(private val binding: FlutterPlugin.FlutterPluginBinding) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<*, *>
        val placeholderId =  creationParams.getRequired<String>("placeholderId")
        val overrideDefaultBehavior = creationParams.getRequired<Boolean>("overrideDefaultBehavior")
        val trackActions = creationParams.getRequired<Boolean>("trackActions")
        val maxMessagesCount = creationParams.getOptional<Int>("maxMessagesCount")
        val scrollDelay = creationParams.getOptional<Int>("scrollDelay")
        val filtrationSet = creationParams.getRequired<Boolean>("filtrationSet")
        val sortingSet = creationParams.getRequired<Boolean>("sortingSet")
        val inAppContentBlockCarousel = Exponea.getInAppContentBlocksCarousel(
            context!!,
            placeholderId,
            maxMessagesCount = maxMessagesCount,
            scrollDelay = scrollDelay,
        )

        return FlutterInAppContentBlockCarousel(
            context,
            viewId,
            placeholderId,
            inAppContentBlockCarousel,
            overrideDefaultBehavior,
            trackActions,
            filtrationSet,
            sortingSet,
            binding,
        )
    }
}