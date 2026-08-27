package com.exponea.widget

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.ScrollView
import com.exponea.data.InAppContentBlockActionCoder
import com.exponea.sdk.models.InAppContentBlock
import com.exponea.sdk.models.InAppContentBlockAction
import com.exponea.sdk.models.InAppContentBlockCallback
import com.exponea.sdk.util.ExponeaGson
import com.exponea.sdk.view.InAppContentBlockPlaceholderView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class FlutterInAppContentBlockPlaceholder(
    private val context: Context,
    private val id: Int,
    private val placeholderId: String,
    private val inAppContentBlockPlaceholder: InAppContentBlockPlaceholderView?,
    private val overrideDefaultBehavior: Boolean,
    binding: FlutterPlugin.FlutterPluginBinding,
) : PlatformView {

    companion object {
        private const val CHANNEL_NAME = "com.exponea/InAppContentBlockPlaceholder"
        private const val METHOD_ON_IN_APP_CONTENT_BLOCK_EVENT = "onInAppContentBlockEvent"
    }

    private var channel: MethodChannel? = null
    private var view: View? = null
    private var lastReportedHeight: Int? = null

    init {
        if (inAppContentBlockPlaceholder != null) {
            channel = MethodChannel(binding.binaryMessenger, "$CHANNEL_NAME/$id")

            val origBehaviour = inAppContentBlockPlaceholder.behaviourCallback
            inAppContentBlockPlaceholder.behaviourCallback = object : InAppContentBlockCallback {
                override fun onActionClicked(
                    placeholderId: String,
                    contentBlock: InAppContentBlock,
                    action: InAppContentBlockAction
                ) {
                    if (!overrideDefaultBehavior) {
                        origBehaviour.onActionClicked(placeholderId, contentBlock, action)
                    }
                    val payload: Map<String, Any?> = mapOf(
                            "eventType" to "onActionClicked",
                            "placeholderId" to placeholderId,
                            "contentBlock" to ExponeaGson.instance.toJson(contentBlock),
                            "action" to InAppContentBlockActionCoder.encode(action)
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_EVENT, payload)
                }

                override fun onCloseClicked(
                    placeholderId: String,
                    contentBlock: InAppContentBlock
                ) {
                    if (!overrideDefaultBehavior) {
                        origBehaviour.onCloseClicked(placeholderId, contentBlock)
                    }
                    val payload: Map<String, Any?> = mapOf(
                            "eventType" to "onCloseClicked",
                            "placeholderId" to placeholderId,
                            "contentBlock" to ExponeaGson.instance.toJson(contentBlock)
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_EVENT, payload)
                }

                override fun onError(
                    placeholderId: String,
                    contentBlock: InAppContentBlock?,
                    errorMessage: String
                ) {
                    if (!overrideDefaultBehavior) {
                        origBehaviour.onError(placeholderId, contentBlock, errorMessage)
                    }
                    val payload: Map<String, Any?> = mapOf(
                            "eventType" to "onError",
                            "placeholderId" to placeholderId,
                            "contentBlock" to ExponeaGson.instance.toJson(contentBlock),
                            "errorMessage" to errorMessage
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_EVENT, payload)
                }

                override fun onMessageShown(
                    placeholderId: String,
                    contentBlock: InAppContentBlock
                ) {
                    if (!overrideDefaultBehavior) {
                        origBehaviour.onMessageShown(placeholderId, contentBlock)
                    }
                    val payload: Map<String, Any?> = mapOf(
                            "eventType" to "onMessageShown",
                            "placeholderId" to placeholderId,
                            "contentBlock" to ExponeaGson.instance.toJson(contentBlock)
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_EVENT, payload)
                }

                override fun onNoMessageFound(placeholderId: String) {
                    lastReportedHeight = null
                    if (!overrideDefaultBehavior) {
                        origBehaviour.onNoMessageFound(placeholderId)
                    }
                    val payload: Map<String, Any?> = mapOf(
                            "eventType" to "onNoMessageFound",
                            "placeholderId" to placeholderId,
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_EVENT, payload)
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
            inAppContentBlockPlaceholder.setOnHeightUpdateListener { height ->
                notifyHeightUpdate(height)
            }
            inAppContentBlockPlaceholder.setOnContentReadyListener { contentLoaded ->
                if (!contentLoaded) {
                    return@setOnContentReadyListener
                }
                inAppContentBlockPlaceholder.post {
                    if (inAppContentBlockPlaceholder.width == 0) {
                        return@post
                    }
                    inAppContentBlockPlaceholder.measure(
                        View.MeasureSpec.makeMeasureSpec(
                            inAppContentBlockPlaceholder.width,
                            View.MeasureSpec.EXACTLY
                        ),
                        View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
                    )
                    notifyHeightUpdate(inAppContentBlockPlaceholder.measuredHeight)
                }
            }
        }

    }

    private fun notifyHeightUpdate(height: Int) {
        if (height == lastReportedHeight) {
            return
        }
        lastReportedHeight = height
        val payload: Map<String, Any?> = mapOf(
            "eventType" to "onHeightUpdate",
            "placeholderId" to placeholderId,
            "height" to height
        )
        CoroutineScope(Dispatchers.Main).launch {
            channel?.invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_EVENT, payload)
        }
    }

    override fun getView(): View? {
        if (view != null) {
            return view
        }
        if (inAppContentBlockPlaceholder == null) {
            return null
        }
        // Place the ad view inside a scroll view. This allows the height of the ad view to overflow
        // its container so we can calculate the height and send it back to flutter.
        val scrollView = ScrollView(context)
        scrollView.clipChildren = false
        scrollView.isVerticalScrollBarEnabled = false
        scrollView.isHorizontalScrollBarEnabled = false
        scrollView.addView(
            inAppContentBlockPlaceholder, ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
            )
        )
        view = scrollView
        return scrollView
    }

    override fun dispose() {
        channel = null
        view = null
    }

    override fun onFlutterViewAttached(flutterView: View) {
        // placeholder will reload content itself
    }
}
