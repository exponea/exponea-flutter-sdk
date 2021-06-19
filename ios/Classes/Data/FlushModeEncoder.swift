//
//  FlushModeEncoder.swift
//  exponea
//

import Foundation
import ExponeaSDK

class FlushModeEncoder {
    let defaultPeriod = 5 * 60 // 5 minutes

    func encode(_ value: FlushingMode) -> String {
        switch value {
        case .automatic:
            return "APP_CLOSE"
        case .immediate:
            return "IMMEDIATE"
        case .periodic:
            return "PERIOD"
        case .manual:
            return "MANUAL"
        }
    }

    func decode(_ value: String) throws -> FlushingMode {
        switch value {
        case "APP_CLOSE":
            return .automatic
        case "IMMEDIATE":
            return .immediate
        case "PERIOD":
            return .periodic(defaultPeriod)
        case "MANUAL":
            return .manual
        default:
            throw ExponeaDataError.invalidValue(for: "flush mode")
        }
    }
}
