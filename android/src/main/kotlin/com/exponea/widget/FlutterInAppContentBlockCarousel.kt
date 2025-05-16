package com.exponea.widget

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.ScrollView
import com.exponea.data.FlutterContentBlockCarouselSelector
import com.exponea.data.InAppContentBlockActionCoder
import com.exponea.sdk.models.ContentBlockCarouselCallback
import com.exponea.sdk.models.InAppContentBlock
import com.exponea.sdk.models.InAppContentBlockAction
import com.exponea.sdk.util.ExponeaGson
import com.exponea.sdk.view.ContentBlockCarouselView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView


class FlutterInAppContentBlockCarousel(
    private val context: Context,
    id: Int,
    private val placeholderId: String,
    private val inAppContentBlockCarousel: ContentBlockCarouselView?,
    private val overrideDefaultBehavior: Boolean,
    private val trackActions: Boolean,
    private val filtrationSet: Boolean,
    private val sortingSet: Boolean,
    binding: FlutterPlugin.FlutterPluginBinding,
) : PlatformView, MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.exponea/InAppContentBlockCarousel"
        private const val METHOD_ON_IN_APP_CONTENT_BLOCK_CAROUSEL_EVENT = "onInAppContentBlockCarouselEvent"
        private const val METHOD_FILTER_CONTENT_BLOCKS = "filterContentBlocks"
        private const val METHOD_SORT_CONTENT_BLOCKS = "sortContentBlocks"
        private const val METHOD_FILTER_CONTENT_BLOCKS_RESULT = "filterContentBlocksResult"
        private const val METHOD_SORT_CONTENT_BLOCKS_RESULT = "sortContentBlocksResult"
    }

    private var channel: MethodChannel? = null
    private var view: View? = null

    init {
        if (inAppContentBlockCarousel != null) {
            channel = MethodChannel(binding.binaryMessenger, "$CHANNEL_NAME/$id")
            channel?.setMethodCallHandler(this)
            val overrideBehavior = overrideDefaultBehavior
            val track = trackActions
            if (filtrationSet || sortingSet) {
                inAppContentBlockCarousel.contentBlockSelector = FlutterContentBlockCarouselSelector(
                    filterCallback = if (filtrationSet) { source ->
                        CoroutineScope(Dispatchers.Main).launch {
                            channel?.invokeMethod(
                                METHOD_FILTER_CONTENT_BLOCKS,
                                source.map { ExponeaGson.instance.toJson(it) }
                            )
                        }
                    } else null,
                    sortCallback = if (sortingSet) { source ->
                        CoroutineScope(Dispatchers.Main).launch {
                            channel?.invokeMethod(
                                METHOD_SORT_CONTENT_BLOCKS,
                                source.map { ExponeaGson.instance.toJson(it) }
                            )
                        }
                    } else null
                )
            }
            inAppContentBlockCarousel.behaviourCallback = object : ContentBlockCarouselCallback {
                override val overrideDefaultBehavior: Boolean
                    get() = overrideBehavior
                override val trackActions: Boolean
                    get() = track

                override fun onActionClicked(
                    placeholderId: String,
                    contentBlock: InAppContentBlock,
                    action: InAppContentBlockAction
                ) {
                    val payload: Map<String, Any?> = mapOf(
                        "eventType" to "onActionClicked",
                        "placeholderId" to placeholderId,
                        "contentBlock" to ExponeaGson.instance.toJson(contentBlock),
                        "action" to InAppContentBlockActionCoder.encode(action)
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_CAROUSEL_EVENT, payload)
                }

                override fun onCloseClicked(
                    placeholderId: String,
                    contentBlock: InAppContentBlock
                ) {
                    val payload: Map<String, Any?> = mapOf(
                        "eventType" to "onCloseClicked",
                        "placeholderId" to placeholderId,
                        "contentBlock" to ExponeaGson.instance.toJson(contentBlock)
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_CAROUSEL_EVENT, payload)
                }

                override fun onError(
                    placeholderId: String,
                    contentBlock: InAppContentBlock?,
                    errorMessage: String
                ) {
                    val payload: Map<String, Any?> = mapOf(
                        "eventType" to "onError",
                        "placeholderId" to placeholderId,
                        "contentBlock" to ExponeaGson.instance.toJson(contentBlock),
                        "errorMessage" to errorMessage
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_CAROUSEL_EVENT, payload)
                }

                override fun onHeightUpdate(placeholderId: String, height: Int) {
                    val payload: Map<String, Any?> = mapOf(
                        "eventType" to "onHeightUpdate",
                        "placeholderId" to placeholderId,
                        "height" to height
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_CAROUSEL_EVENT, payload)
                }

                override fun onMessageShown(
                    placeholderId: String,
                    contentBlock: InAppContentBlock,
                    index: Int,
                    count: Int
                ) {
                    val payload: Map<String, Any?> = mapOf(
                        "eventType" to "onMessageShown",
                        "placeholderId" to placeholderId,
                        "contentBlock" to ExponeaGson.instance.toJson(contentBlock),
                        "index" to index,
                        "count" to count
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_CAROUSEL_EVENT, payload)
                }

                override fun onMessagesChanged(count: Int, messages: List<InAppContentBlock>) {
                    val payload: Map<String, Any?> = mapOf(
                        "eventType" to "onMessagesChanged",
                        "count" to count,
                        "messages" to messages.map { ExponeaGson.instance.toJson(it) }
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_CAROUSEL_EVENT, payload)
                }

                override fun onNoMessageFound(placeholderId: String) {
                    val payload: Map<String, Any?> = mapOf(
                        "eventType" to "onNoMessageFound",
                        "placeholderId" to placeholderId,
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_CAROUSEL_EVENT, payload)
                }

                fun invokeMethod(method: String, arguments: Map<String, Any?>) {
                    CoroutineScope(Dispatchers.Main).launch {
                        channel?.invokeMethod(
                            method,
                            arguments
                        )
                    }
                }

            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_FILTER_CONTENT_BLOCKS_RESULT -> {
                val source = (call.arguments as List<Any?>).map { ExponeaGson.instance.fromJson(it as String, InAppContentBlock::class.java) }
                (inAppContentBlockCarousel?.contentBlockSelector as? FlutterContentBlockCarouselSelector)?.onFilterResponse(source)
            }
            METHOD_SORT_CONTENT_BLOCKS_RESULT -> {
                val source = (call.arguments as List<Any?>).map { ExponeaGson.instance.fromJson(it as String, InAppContentBlock::class.java) }
                (inAppContentBlockCarousel?.contentBlockSelector as? FlutterContentBlockCarouselSelector)?.onSortResponse(source)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun getView(): View? {
        if (view != null) {
            return view
        }
        if (inAppContentBlockCarousel == null) {
            return null
        }
        // Place the ad view inside a scroll view. This allows the height of the ad view to overflow
        // its container so we can calculate the height and send it back to flutter.
        val scrollView = ScrollView(context)
        scrollView.clipChildren = false
        scrollView.isVerticalScrollBarEnabled = false
        scrollView.isHorizontalScrollBarEnabled = false
        scrollView.addView(
            inAppContentBlockCarousel, ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
            )
        )
        view = scrollView
        return scrollView
    }

    override fun dispose() {
        channel?.setMethodCallHandler(null)
        channel = null
        view = null
    }
}