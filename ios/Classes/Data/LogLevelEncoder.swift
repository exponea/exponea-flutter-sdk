//
//  LogLevelEncoder.swift
//  exponea
//

import Foundation
import ExponeaSDK

class LogLevelEncoder {
    func encode(_ value: LogLevel) -> String {
        switch value {
        case .none:
            return "OFF"
        case .verbose:
            return "VERBOSE"
        case .warning:
            return "WARN"
        case .error:
            return "ERROR"
        }
    }

    func decode(_ value: String) throws -> LogLevel {
        switch value {
        case "OFF":
            return .none
        case "ERROR":
            return .error
        case "WARN":
            return .warning
        case "VERBOSE":
            return .verbose
        case "INFO", "DEBUG":
            throw ExponeaError.notAvailableForPlatform(name: "\(value) log level")
        default:
            throw ExponeaDataError.invalidValue(for: "log level")
        }
    }
}
