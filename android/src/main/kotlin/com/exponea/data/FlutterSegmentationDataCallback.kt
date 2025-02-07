package com.exponea.data

import com.exponea.sdk.models.Segment
import com.exponea.sdk.models.SegmentationDataCallback
import com.exponea.sdk.util.Logger
import java.util.UUID

class FlutterSegmentationDataCallback(
    override val exposingCategory: String,
    override var includeFirstLoad: Boolean,
    private val callback: (FlutterSegmentationDataCallback, List<Segment>) -> Unit
) : SegmentationDataCallback() {
    val instanceId = UUID.randomUUID().toString()

    override fun onNewData(segments: List<Segment>) {
        Logger.d(this, "Segments: New segments for '$exposingCategory' received: $segments")
        callback.invoke(this, segments)
    }
}