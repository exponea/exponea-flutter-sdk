package com.exponea.widget

import com.exponea.exception.ExponeaDataException

internal fun <T> Map<*, *>.getRequired(key: String): T {
    val value = this[key] ?: throw ExponeaDataException.missingProperty(key)
    try {
        return value as T
    } catch (e: Exception) {
        throw ExponeaDataException.invalidType(key)
    }
}

internal fun <T> Map<*, *>.getOptional(key: String): T? {
    val value = this[key]
    if (value == null) {
        return null
    }
    try {
        return value as T
    } catch (e: Exception) {
        throw ExponeaDataException.invalidType(key)
    }
}
