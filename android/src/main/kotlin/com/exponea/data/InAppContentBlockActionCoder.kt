package com.exponea.data

import com.exponea.getNullSafely
import com.exponea.getRequired
import com.exponea.sdk.models.InAppContentBlockAction
import com.exponea.sdk.models.InAppContentBlockActionType

class InAppContentBlockActionCoder {
    companion object {
        fun encode(source: InAppContentBlockAction): Map<String, Any?> {
            return mapOf(
                "type" to source.type.toString(),
                "name" to source.name,
                "url" to source.url,
            )
        }

        fun decode(source: Map<String, Any?>): InAppContentBlockAction {
            return InAppContentBlockAction(
                type = InAppContentBlockActionType.valueOf(source.getRequired("type")),
                name = source.getNullSafely("name"),
                url = source.getNullSafely("url")
            )
        }
    }
}