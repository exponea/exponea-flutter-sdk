//
//  JsonDataParser.swift
//  Exponea
//

import Foundation
import ExponeaSDK

struct JsonDataParser {
    static func parse(dictionary: [String: Any?]) throws -> [String: JSONConvertible] {
        var data: [String: JSONConvertible] = [:]
        try dictionary.forEach { key, value in
            if let usedValue = value {
                data[key] = try parseValue(value: usedValue)
            }
        }
        return data
    }
    
    static func parseArray(array: NSArray) throws -> [JSONConvertible] {
        return try array.map { try parseValue(value: $0) }
    }
    
    static func parseValue(value: Any) throws -> JSONConvertible {
        if let dictionary = value as? [String:Any?] {
            return try parse(dictionary: dictionary)
        } else if let array = value as? NSArray {
            return try parseArray(array: array)
        } else if let number = value as? NSNumber {
            if number === kCFBooleanFalse {
                return false
            } else if number === kCFBooleanTrue {
                return true
            } else {
                return number.doubleValue
            }
        } else if let string = value as? NSString {
            return string
        }
        throw ExponeaDataError.invalidType(for: "value in data '\(type(of: value))'")
    }
}
