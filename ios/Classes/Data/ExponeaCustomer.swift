//
//  ExponeaCustomer.swift
//  exponea
//

import Foundation
import ExponeaSDK

class ExponeaCustomer {
    let ids: [String:String]
    let properties: [String:JSONConvertible]
    
    init(_ data: [String:Any?]) throws {
        self.ids = try data.getOptional("ids") ?? [:]
        if let properties = data["properties"] as? [String:Any] {
            self.properties = try properties.mapValues({ (value: Any) -> JSONConvertible in
                try JsonDataParser.parseValue(value: value)
            })
        } else {
            self.properties = [:]
        }
    }
}
