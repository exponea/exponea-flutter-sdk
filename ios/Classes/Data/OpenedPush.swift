//
//  OpenedPush.swift
//  exponea
//

import Foundation

enum PushAction {
    case app
    case deeplink
    case web

    static func decode(value: String) throws -> PushAction {
        switch value {
        case "app":
            return .app
        case "deeplink":
            return .deeplink
        case "web":
            return .web
        default:
            throw ExponeaDataError.invalidValue(for: "push action")
        }
    }

    static func encode(value: PushAction) -> String {
        switch value {
        case .app:
            return "app"
        case deeplink:
            return "deeplink"
        case web:
            return "web"
        }
    }
}

class OpenedPush {
    let action: PushAction
    let url: String?
    let data: [String:Any]?

    init(action: PushAction, url: String? = nil, data: [String:Any]? = nil) {
        self.action = action
        self.url = url
        self.data = data
    }

    init(_ data: [String:Any?]) throws {
        self.action = try PushAction.decode(value: try data.getRequired("action"))
        self.url = try data.getOptional("url")
        self.data = try data.getOptional("data")
    }

    func toMap() -> [String:Any?] {
        return [
            "action": PushAction.encode(value: self.action),
            "url": self.url,
            "data": self.data,
        ].filter { (key, value) -> Bool in value != nil}
    }
}
