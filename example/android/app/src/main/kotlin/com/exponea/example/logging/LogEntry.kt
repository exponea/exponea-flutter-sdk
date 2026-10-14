package com.exponea.example.logging

data class LogEntry(
    val timestamp: Long,
    val level: Level,
    val tag: String,
    val message: String,
) {
    enum class Level(val wireName: String) {
        VERBOSE("verbose"),
        DEBUG("debug"),
        INFO("info"),
        WARN("warn"),
        ERROR("error");

        companion object {
            fun fromShort(short: String): Level = when (short.trim().uppercase()) {
                "V" -> VERBOSE
                "D" -> DEBUG
                "I" -> INFO
                "W" -> WARN
                "E", "F" -> ERROR
                else -> INFO
            }
        }
    }

    fun toWireMap(): Map<String, Any> = mapOf(
        "timestamp" to timestamp,
        "level" to level.wireName,
        "tag" to tag,
        "message" to message,
    )
}
