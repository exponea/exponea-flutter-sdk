package com.exponea.data

import com.exponea.sdk.models.Consent

class ConsentEncoder {
    companion object {
        fun encode(consent: Consent): Map<String, Any?> {
            return mapOf(
                "id" to consent.id,
                "legitimateInterest" to consent.legitimateInterest,
                "sources" to mapOf(
                    "createdFromCRM" to consent.sources.createdFromCRM,
                    "imported" to consent.sources.imported,
                    "fromConsentPage" to consent.sources.fromConsentPage,
                    "privateAPI" to consent.sources.privateAPI,
                    "publicAPI" to consent.sources.publicAPI,
                    "trackedFromScenario" to consent.sources.trackedFromScenario
                ),
                "translations" to consent.translations
            )
        }
    }
}
