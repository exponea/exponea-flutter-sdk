package com.exponea.data

import com.exponea.getRequired
import com.exponea.sdk.models.DateFilter
import com.exponea.sdk.models.InAppMessage
import com.exponea.sdk.models.InAppMessagePayload

import com.exponea.sdk.models.eventfilter.EventFilter
import com.google.gson.Gson

class InAppMessageCoder {
    companion object {
        fun encode(source: InAppMessage): Map<String, Any?> {
            return mapOf(
                "id" to source.id,
                "name" to source.name,
                "messageType" to source.messageType.value,
                "frequency" to source.frequency?.value,
                "payload" to source.payload?.let {
                    Gson().toJson(it)
                },
                "variantId" to source.variantId,
                "variantName" to source.variantName,
                "trigger" to source.trigger?.let {
                    Gson().toJson(it)
                },
                "dateFilter" to Gson().toJson(source.dateFilter),
                "loadPriority" to source.priority,
                "loadDelay" to source.delay,
                "closeTimeout" to source.timeout,
                "payloadHtml" to source.payloadHtml,
                "isHtml" to source.isHtml,
                "hasTrackingConsent" to source.hasTrackingConsent,
                "consentCategoryTracking" to source.consentCategoryTracking,
            )
        }

        fun decode(source: Map<String, Any?>): InAppMessage {
            val gson = Gson()
            return InAppMessage(
                id = source.getRequired("id"),
                name = source.getRequired("name"),
                rawMessageType = source.getOptional("messageType"),
                rawFrequency = source.getRequired("frequency"),
                payload = gson.fromJson(source.getOptional<String>("payload"), InAppMessagePayload::class.java),
                variantId = source.getRequired("variantId"),
                variantName = source.getRequired("variantName"),
                trigger = gson.fromJson(source.getOptional<String>("trigger"), EventFilter::class.java),
                dateFilter = gson.fromJson(source.getOptional<String>("dateFilter"), DateFilter::class.java),
                priority = source.getOptional("loadPriority"),
                delay = source.getOptional<Int>("loadDelay")?.toLong(),
                timeout = source.getOptional<Int>("closeTimeout")?.toLong(),
                payloadHtml = source.getOptional("payloadHtml"),
                isHtml = source.getOptional("isHtml"),
                rawHasTrackingConsent = source.getOptional("hasTrackingConsent"),
                consentCategoryTracking = source.getOptional("consentCategoryTracking"),
            )
        }
    }
}