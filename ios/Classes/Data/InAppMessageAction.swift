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
            "message": try? InAppMessageCoder.encode(message),
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
