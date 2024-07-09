package com.exponea.data

import com.exponea.currentTimeSeconds
import com.exponea.getNullSafely
import com.exponea.getNullSafelyMap
import com.exponea.sdk.models.CampaignData
import com.exponea.sdk.models.NotificationAction
import com.exponea.sdk.models.NotificationData
import com.exponea.sdk.util.GdprTracking

class NotificationCoder {
    companion object {
        fun decodeNotificationData(source: Map<String, Any?>): NotificationData? {
            val attributes = source.getNullSafelyMap<Any>("data") as? HashMap<String, Any>
                ?: source.getNullSafelyMap<Any>("attributes") as? HashMap<String, Any>
                ?: return null
            val campaignData =
                source.getNullSafelyMap<Any>("url_params")?.let { decodeCampaignData(it) }
                    ?: CampaignData()
            return NotificationData(
                attributes,
                campaignData,
                source.getNullSafely("consent_category_tracking"),
                GdprTracking.hasTrackingConsent(source.getNullSafely("has_tracking_consent"))
            )
        }

        fun decodeNotificationAction(source: Map<String, Any?>): NotificationAction? {
            val actionType: String = source.getNullSafely("actionType") ?: return null
            return NotificationAction(
                actionType = actionType,
                actionName = source.getNullSafely("actionName"),
                url = source.getNullSafely("url")
            )
        }

        fun decodeCampaignData(source: Map<String, Any?>): CampaignData {
            return CampaignData(
                source = source.getNullSafely("utm_source"),
                campaign = source.getNullSafely("utm_campaign"),
                content = source.getNullSafely("utm_content"),
                medium = source.getNullSafely("utm_medium"),
                term = source.getNullSafely("utm_term"),
                payload = source.getNullSafely("xnpe_cmp"),
                createdAt = currentTimeSeconds(),
                completeUrl = null
            )
        }
    }
}