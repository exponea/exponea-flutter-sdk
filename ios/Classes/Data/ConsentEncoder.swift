//
//  ConsentEncoder.swift
//  exponea
//

import Foundation
import ExponeaSDK

class ConsentEncoder {
    static func encode(_ consent: Consent) -> [String:Any?] {
        return [
            "id": consent.id,
            "legitimateInterest": consent.legitimateInterest,
            "sources": [
                "createdFromCRM": consent.sources.isCreatedFromCRM,
                "imported": consent.sources.isImported,
                "fromConsentPage": consent.sources.isFromConsentPage,
                "privateAPI": consent.sources.privateAPI,
                "publicAPI": consent.sources.publicAPI,
                "trackedFromScenario": consent.sources.isTrackedFromScenario
            ],
            "translations": consent.translations
        ]
    }
}
