package com.exponea.widget

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.ScrollView
import com.exponea.data.InAppContentBlockActionCoder
import com.exponea.sdk.models.InAppContentBlock
import com.exponea.sdk.models.InAppContentBlockAction
import com.exponea.sdk.models.InAppContentBlockCallback
import com.exponea.sdk.models.InAppContentBlockActionType
import com.exponea.sdk.util.Logger
import com.exponea.sdk.util.HtmlNormalizer
import com.exponea.sdk.util.HtmlNormalizer.NormalizedResult
import com.exponea.sdk.view.InAppContentBlockPlaceholderView
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView

class FlutterInAppContentBlockPlaceholder(
    private val context: Context,
    private val id: Int,
    private val placeholderId: String,
    private val inAppContentBlockPlaceholder: InAppContentBlockPlaceholderView?,
    private val overrideDefaultBehavior: Boolean,
    binding: FlutterPlugin.FlutterPluginBinding,
    private val gson: Gson = Gson(),
) : PlatformView, MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.exponea/InAppContentBlockPlaceholder"
        private const val METHOD_ON_IN_APP_CONTENT_BLOCK_HTML_CHANGED = "onInAppContentBlockHtmlChanged"
        private const val METHOD_ON_IN_APP_CONTENT_BLOCK_EVENT = "onInAppContentBlockEvent"
        private const val METHOD_HANDLE_IN_APP_CONTENT_BLOCK_CLICK = "handleInAppContentBlockClick"
    }

    private var channel: MethodChannel? = null
    private var view: View? = null

    init {
        if (inAppContentBlockPlaceholder != null) {
            channel = MethodChannel(binding.binaryMessenger, "$CHANNEL_NAME/$id")
            channel!!.setMethodCallHandler(this)

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
                            "contentBlock" to gson.toJson(contentBlock),
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
                            "contentBlock" to gson.toJson(contentBlock)
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
                            "contentBlock" to gson.toJson(contentBlock),
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
                    val normalizedResult = getNormalizedResult(contentBlock, placeholderId)
                    val arguments: Map<String, String?> =
                        mapOf("htmlContent" to normalizedResult?.html)
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_HTML_CHANGED, arguments)
                    val payload: Map<String, Any?> = mapOf(
                            "eventType" to "onMessageShown",
                            "placeholderId" to placeholderId,
                            "contentBlock" to gson.toJson(contentBlock)
                    )
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_EVENT, payload)
                }

                override fun onNoMessageFound(placeholderId: String) {
                    if (!overrideDefaultBehavior) {
                        origBehaviour.onNoMessageFound(placeholderId)
                    }
                    val arguments: Map<String, String?> = mapOf("htmlContent" to null)
                    invokeMethod(METHOD_ON_IN_APP_CONTENT_BLOCK_HTML_CHANGED, arguments)
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
        }

    }

    private fun getNormalizedResult(
        contentBlock: InAppContentBlock,
        placeholderId: String
    ): NormalizedResult? {
        val rawHtml = contentBlock.htmlContent ?: return null
        val normalizer = HtmlNormalizer(context, rawHtml)
        val normalizeConf = HtmlNormalizer.HtmlNormalizerConfig(
            makeResourcesOffline = true, ensureCloseButton = false
        )
        val normalizedHtmlResult = normalizer.normalize(normalizeConf)
        if (!normalizedHtmlResult.valid) {
            Logger.e(
                this,
                """
                InAppCB: Unable to normalize HTML content for block ${contentBlock.id} for placeholder $placeholderId
                """.trimIndent()
            )
        }
        return normalizedHtmlResult
    }

    private fun determineInAppActionType(url: String): InAppContentBlockActionType {
        if ("https://exponea.com/close_action" == url) {
            return InAppContentBlockActionType.CLOSE
        }
        if (url.startsWith("http://") || url.startsWith("https://")) {
            return InAppContentBlockActionType.BROWSER
        } else {
            return InAppContentBlockActionType.DEEPLINK
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {

        when (call.method) {
            METHOD_HANDLE_IN_APP_CONTENT_BLOCK_CLICK -> {

                if (inAppContentBlockPlaceholder == null) {
                    result.error(
                        "InAppCB",
                        "Handling of url was invoked even when InAppCB is not initialized",
                        null
                    )
                    return
                }

                val args = call.arguments as Map<String, Any>
                val actionUrl = args["actionUrl"] as? String
                if (actionUrl == null) {
                    result.error(
                        "InAppCB",
                        "unable to parse action URL ",
                        null
                    )
                    return
                }
                inAppContentBlockPlaceholder.invokeActionClick(actionUrl)
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
        channel?.setMethodCallHandler(null)
        channel = null
        view = null
    }

    override fun onFlutterViewAttached(flutterView: View) {
        // placeholder will reload content itself
    }
}