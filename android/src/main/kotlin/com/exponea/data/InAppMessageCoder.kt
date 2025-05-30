package com.exponea.data

import com.exponea.getRequired
import com.exponea.sdk.models.DateFilter
import com.exponea.sdk.models.InAppMessage
import com.exponea.sdk.models.InAppMessagePayload
import com.exponea.sdk.models.eventfilter.EventFilter
import com.exponea.sdk.util.ExponeaGson

class InAppMessageCoder {
    companion object {
        fun encode(source: InAppMessage): Map<String, Any?> {
            return mapOf(
                "id" to source.id,
                "name" to source.name,
                "messageType" to source.messageType.value,
                "frequency" to source.frequency?.value,
                "payload" to source.payload?.let {
                    ExponeaGson.instance.toJson(it)
                },
                "variantId" to source.variantId,
                "variantName" to source.variantName,
                "trigger" to source.trigger?.let {
                    ExponeaGson.instance.toJson(it)
                },
                "dateFilter" to ExponeaGson.instance.toJson(source.dateFilter),
                "loadPriority" to source.priority,
                "loadDelay" to source.delay,
                "closeTimeout" to source.timeout,
                "payloadHtml" to source.payloadHtml,
                "isHtml" to source.isHtml,
                "hasTrackingConsent" to source.hasTrackingConsent,
                "consentCategoryTracking" to source.consentCategoryTracking,
                "isRichText" to source.isRichText,
            )
        }

        fun decode(source: Map<String, Any?>): InAppMessage {
            return InAppMessage(
                id = source.getRequired("id"),
                name = source.getRequired("name"),
                rawMessageType = source.getOptional("messageType"),
                rawFrequency = source.getRequired("frequency"),
                payload = ExponeaGson.instance.fromJson(source.getOptional<String>("payload"), InAppMessagePayload::class.java),
                variantId = source.getRequired("variantId"),
                variantName = source.getRequired("variantName"),
                trigger = ExponeaGson.instance.fromJson(source.getOptional<String>("trigger"), EventFilter::class.java),
                dateFilter = ExponeaGson.instance.fromJson(source.getOptional<String>("dateFilter"), DateFilter::class.java),
                priority = source.getOptional("loadPriority"),
                delay = source.getOptional<Int>("loadDelay")?.toLong(),
                timeout = source.getOptional<Int>("closeTimeout")?.toLong(),
                payloadHtml = source.getOptional("payloadHtml"),
                isHtml = source.getOptional("isHtml"),
                rawHasTrackingConsent = source.getOptional("hasTrackingConsent"),
                consentCategoryTracking = source.getOptional("consentCategoryTracking"),
                isRichText = source.getOptional("isRichText"),
            )
        }
    }
}