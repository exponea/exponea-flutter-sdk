package com.exponea.data

data class Customer(val ids: Map<String, String?>, val properties: Map<String, Any>) {
    companion object {
        fun fromMap(map: Map<String, Any?>): Customer {
            return Customer(
                ids = (map["ids"] as Map<String, String?>?) ?: mapOf(),
                properties = (map["properties"] as Map<String, Any>?) ?: mapOf()
            )
        }
    }
}
