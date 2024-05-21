//
//  InAppContentBlockActionCoder.swift
//  exponea
//

import Foundation
import ExponeaSDK

class InAppContentBlockActionCoder {

        static func encode(_ source: InAppContentBlockAction) throws -> [String:Any?] {
            return [
                "type": String(describing: source.type).uppercased(),
                "name": source.name,
                "url": source.url,
            ]
        }

        static func decode(_ source: [String:Any?]) throws -> InAppContentBlockAction {
            var type: InAppContentBlockActionType = .close
            if let typeString: String = try source.getRequired("type") {
                switch typeString {
                case "DEEPLINK": type = .deeplink
                case "BROWSER": type = .browser
                case "CLOSE": type = .close
                default: throw ExponeaDataError.invalidValue(for: "type")
                }
            }
            return InAppContentBlockAction(
                name: try source.getOptional("name"),
                url: try source.getOptional("url"),
                type: type
            )
        }
    
}
