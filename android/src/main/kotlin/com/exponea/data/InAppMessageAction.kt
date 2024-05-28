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
            "message" to InAppMessageCoder.encode(message),
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
