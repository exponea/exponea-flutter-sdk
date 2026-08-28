//
//  SdkAuthError.swift
//  exponea
//

import Foundation

class SdkAuthError {
    let errorCode: String
    let customerIds: [String: String]

    init(errorCode: String, customerIds: [String: String] = [:]) {
        self.errorCode = errorCode
        self.customerIds = customerIds
    }

    init(_ data: [String: Any?]) throws {
        self.errorCode = try data.getRequired("errorCode")
        let ids: [String: Any?] = try data.getOptional("customerIds") ?? [:]
        self.customerIds = ids.reduce(into: [String: String]()) { result, item in
            let value = item.value
            if value is NSNull { return }
            result[item.key] = String(describing: value)
        }
    }

    func toMap() -> [String: Any?] {
        return [
            "errorCode": errorCode,
            "customerIds": customerIds,
        ]
    }
}

enum SdkAuthErrorReasonMapper {
    static func map(_ reason: Any) -> String {
        switch String(describing: reason) {
        case "expiredSoon":
            return "TOKEN_ABOUT_TO_EXPIRE"
        case "expired":
            return "TOKEN_EXPIRED"
        case "invalid":
            return "TOKEN_REJECTED"
        case "notProvided":
            return "TOKEN_NOT_PROVIDED"
        case "insufficient":
            return "TOKEN_INSUFFICIENT"
        default:
            return "TOKEN_REJECTED"
        }
    }
}
