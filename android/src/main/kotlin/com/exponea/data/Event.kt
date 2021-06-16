package com.exponea.data

data class Event(val name: String, val properties: Map<String, Any>, val timestamp: Double?) {
    companion object {
        fun fromMap(map: Map<String, Any?>): Event {
            return Event(
                name = map["name"] as String? ?: throw IllegalStateException("Event.name is required!"),
                properties = (map["properties"] as Map<String, Any>?) ?: mapOf(),
                timestamp = map["timestamp"] as Double?
            )
        }
    }
}
