package com.exponea.data

import com.exponea.getNullSafely
import com.exponea.sdk.models.MessageItem
import com.exponea.sdk.models.MessageItemAction
import com.exponea.sdk.models.MessageItemAction.Type

class AppInboxCoder {
    companion object {
        fun encode(source: MessageItem): Map<String, Any?> {
            return mapOf(
                "id" to source.id,
                "type" to source.rawType,
                "isRead" to source.read,
                "createTime" to source.receivedTime,
                "content" to source.rawContent
            )
        }

        fun decodeAction(source: Map<String, Any?>): MessageItemAction? {
            val sourceType = Type.find(source.getNullSafely("action")) ?: return null
            return MessageItemAction().apply {
                type = sourceType
                title = source.getNullSafely("title")
                url = source.getNullSafely("url")
            }
        }
    }
}