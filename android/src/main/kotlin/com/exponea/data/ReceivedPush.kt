package com.exponea.data

data class ReceivedPush(val data: Map<String, Any>) {
    fun toMap(): Map<String, Any?> {
        return mapOf("data" to data)
    }
}
