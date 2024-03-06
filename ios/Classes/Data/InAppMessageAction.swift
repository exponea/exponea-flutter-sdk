//
//  InAppMessageAction.swift
//  exponea
//

import Foundation
import ExponeaSDK

final class InAppMessageAction {
    let message: InAppMessage
    let button: InAppMessageButton?
    let interaction: Bool
    
    init(message: InAppMessage, button: InAppMessageButton?, interaction: Bool) {
        self.message = message
        self.button = button
        self.interaction = interaction
    }
    
    func toMap() -> [String:Any?]  {
        var data : [String:Any?] = [
            "message": [
                "id": message.id,
                "name": message.name,
                "messageType": message.messageType.rawValue,
                "frequency": message.frequency?.rawValue,
                "payload": message.payload != nil ? try? String(data: JSONEncoder().encode(message.payload), encoding: .utf8) : nil,
                "variantId": message.variantId,
                "variantName": message.variantName,
                "trigger": try? String(data: JSONEncoder().encode(message.trigger), encoding: .utf8),
                "dateFilter": try? String(data: JSONEncoder().encode(message.dateFilter), encoding: .utf8),
                "loadPriority": message.priority,
                "loadDelay": message.delayMS,
                "closeTimeout": message.timeoutMS,
                "payloadHtml": message.payloadHtml,
                "isHtml": message.isHtml,
                "hasTrackingConsent": message.hasTrackingConsent,
                "consentCategoryTracking": message.consentCategoryTracking,
            ],
            "interaction": interaction,
        ]
        if let button {
            data["button"] = [
                "text": button.text,
                "url": button.url
            ]
        }
        return data
    }
}
