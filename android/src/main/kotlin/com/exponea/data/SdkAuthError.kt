package com.exponea.data

import com.exponea.sdk.models.SdkAuthError as NativeSdkAuthError

data class SdkAuthError(
    val errorCode: String,
    val customerIds: Map<String, String> = emptyMap(),
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "errorCode" to errorCode,
            "customerIds" to customerIds,
        )
    }
}

fun NativeSdkAuthError.toBridge(): SdkAuthError {
    val ids = customerIds.mapNotNull { (key, value) ->
        value?.let { key to it }
    }.toMap()
    return SdkAuthError(
        errorCode = errorCode.name,
        customerIds = ids,
    )
}
