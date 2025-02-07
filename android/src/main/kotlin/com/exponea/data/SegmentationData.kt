package com.exponea.data

import com.exponea.sdk.models.Segment

data class SegmentationData(
    val instanceId: String,
    val data: List<Segment>,
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "instanceId" to instanceId,
            "data" to data,
        )
    }
}
