//
//  DictionaryExtensions.swift
//  Exponea
//

import Foundation

extension Dictionary where Key == String, Value == Any? {
    func getOptional<T>(_ property: String) throws -> T? {
        if let value = self[property] {
            guard value != nil else {
                return nil
            }
            guard let value = value as? T else {
                throw ExponeaDataError.invalidType(for: property)
            }
            return value
        }
        return nil
    }

    func getRequired<T>(_ property: String) throws -> T {
        guard let anyValue = self[property] else {
            throw ExponeaDataError.missingProperty(property: property)
        }
        guard let value = anyValue as? T else {
            throw ExponeaDataError.invalidType(for: property)
        }
        return value
    }
}
