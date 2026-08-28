package com.exponea.data

import com.exponea.sdk.models.CustomerIdentity

object CustomerIdentityParser {
    fun parse(map: Map<String, Any?>?): CustomerIdentity? {
        if (map == null) {
            return null
        }

        val customerIdsRaw = map.getOptional<Map<String, Any?>>("customerIds") ?: emptyMap()
        val customerIds = customerIdsRaw.mapValues { entry ->
            entry.value?.toString() ?: ""
        }
        val sdkAuthToken = map.getOptional<String>("sdkAuthToken")

        return if (sdkAuthToken != null) {
            CustomerIdentity(customerIds, sdkAuthToken)
        } else {
            CustomerIdentity(customerIds)
        }
    }
}
