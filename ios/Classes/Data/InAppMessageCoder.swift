//
//  InAppMessageCoder.swift
//  exponea
//

import Foundation
import ExponeaSDK

class InAppMessageCoder {
    static func encode(_ source: InAppMessage) throws -> [String:Any?] {
        return [
            "id": source.id,
            "name": source.name,
            "messageType": source.messageType.rawValue,
            "frequency": source.frequency?.rawValue,
            "payload": source.payload != nil ? try? String(data: JSONEncoder().encode(source.payload), encoding: .utf8) : nil,
            "variantId": source.variantId,
            "variantName": source.variantName,
            "trigger": try? String(data: JSONEncoder().encode(source.trigger), encoding: .utf8),
            "dateFilter": try? String(data: JSONEncoder().encode(source.dateFilter), encoding: .utf8),
            "loadPriority": source.priority,
            "loadDelay": source.delayMS,
            "closeTimeout": source.timeoutMS,
            "payloadHtml": source.payloadHtml,
            "isHtml": source.isHtml,
            "hasTrackingConsent": source.hasTrackingConsent,
            "consentCategoryTracking": source.consentCategoryTracking,
        ]
    }
    
    static func decode(_ source: [String:Any?]) throws -> InAppMessage {
        var payload: InAppMessagePayload? = nil
        if let payloadString: String = try? source.getOptional("payload"),
           let payloadData: Data = payloadString.data(using: .utf8)
        {
            payload = try? JSONDecoder().decode(InAppMessagePayload.self, from: payloadData)
        }
        
        guard let triggerString: String = try source.getRequired("trigger"),
              let triggerData: Data = triggerString.data(using: .utf8),
              let trigger = try? JSONDecoder().decode(EventFilter.self, from: triggerData) else {
            throw ExponeaDataError.missingProperty(property: "trigger")
        }
        
        guard let dateFilterString: String = try source.getRequired("dateFilter"),
              let dateFilterData: Data = dateFilterString.data(using: .utf8),
              let dateFilter = try? JSONDecoder().decode(DateFilter.self, from: dateFilterData) else {
            throw ExponeaDataError.missingProperty(property: "dateFilter")
        }
        
        return InAppMessage(
            id: try source.getRequired("id"),
            name: try source.getRequired("name"),
            rawMessageType: try source.getOptional("messageType"),
            rawFrequency: try source.getRequired("frequency"),
            payload: payload,
            variantId: try source.getRequired("variantId"),
            variantName: try source.getRequired("variantName"),
            trigger: trigger,
            dateFilter: dateFilter,
            priority: try source.getOptional("loadPriority"),
            delayMS: try source.getOptional("loadDelay"),
            timeoutMS: try source.getOptional("closeTimeout"),
            payloadHtml: try source.getOptional("payloadHtml"),
            isHtml: try source.getOptional("isHtml"),
            hasTrackingConsent: try source.getOptional("hasTrackingConsent"),
            consentCategoryTracking: try source.getOptional("consentCategoryTracking")
        )
    }
}
