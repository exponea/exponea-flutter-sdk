package com.exponea.data

data class OpenedPush(
        val action: PushAction,
        val url: String? = null,
        val data: Map<String, Any?>? = null
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
                "action" to action.value,
                "url" to url,
                "data" to data
        ).filterValues { it != null }
    }
}