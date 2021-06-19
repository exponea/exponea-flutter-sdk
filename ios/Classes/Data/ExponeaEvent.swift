//
//  ExponeaEvent.swift
//  exponea
//

import Foundation
import ExponeaSDK

class ExponeaEvent {
    let name: String
    let properties: [String:JSONConvertible]
    let timestamp: Double?
    
    init(_ data: [String:Any?]) throws {
        self.name = try data.getRequired("name")
        if let properties = data["properties"] as? [String:Any] {
            self.properties = try properties.mapValues({ (value: Any) -> JSONConvertible in
                try JsonDataParser.parseValue(value: value)
            })
        } else {
            self.properties = [:]
        }
        self.timestamp = try data.getOptional("timestamp")
    }
}
