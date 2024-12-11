//
//  InAppMessageAction.swift
//  exponea
//

import Foundation
import ExponeaSDK

final class InAppMessageAction {
    let type: InAppMessageActionType
    let message: InAppMessage?
    let button: InAppMessageButton?
    let interaction: Bool?
    let errorMessage: String?
    
    init(type: InAppMessageActionType, message: InAppMessage? = nil, button: InAppMessageButton? = nil, interaction: Bool? = nil, errorMessage: String? = nil) {
        self.type = type
        self.message = message
        self.button = button
        self.interaction = interaction
        self.errorMessage = errorMessage
    }
    
    func toMap() -> [String:Any?]  {
        var data : [String:Any?] = [
            "type": String(describing: type),
        ]
        if let message {
            data["message"] = try? InAppMessageCoder.encode(message)
        }
        if let button {
            data["button"] = [
                "text": button.text,
                "url": button.url
            ]
        }
        if let interaction {
            data["interaction"] = interaction
        }
        if let errorMessage {
            data["errorMessage"] = errorMessage
        }
        return data
    }
}

public enum InAppMessageActionType {
    case click
    case close
    case error
    case show
}
