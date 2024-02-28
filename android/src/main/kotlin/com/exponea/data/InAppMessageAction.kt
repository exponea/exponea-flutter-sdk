package com.exponea.data

import com.exponea.sdk.models.InAppMessage
import com.exponea.sdk.models.InAppMessageButton
import com.google.gson.Gson

data class InAppMessageAction(
    val message: InAppMessage,
    val button: InAppMessageButton?,
    val interaction: Boolean,
    private val gson: Gson = Gson(),
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "message" to mapOf(
                "id" to message.id,
                "name" to message.name,
                "messageType" to message.messageType.value,
                "frequency" to message.frequency?.value,
                "payload" to message.payload?.let {
                    gson.toJson(it)
                },
                "variantId" to message.variantId,
                "variantName" to message.variantName,
                "trigger" to message.trigger?.let {
                    gson.toJson(it)
                },
                "dateFilter" to gson.toJson(message.dateFilter),
                "loadPriority" to message.priority,
                "loadDelay" to message.delay,
                "closeTimeout" to message.timeout,
                "payloadHtml" to message.payloadHtml,
                "isHtml" to message.isHtml,
                "hasTrackingConsent" to message.hasTrackingConsent,
                "consentCategoryTracking" to message.consentCategoryTracking,
            ),
            "button" to button?.let {
                mapOf(
                    "text" to it.text,
                    "url" to it.url
                )
            },
            "interaction" to interaction
        ).filterValues { it != null }
    }
}
