//
//  RawData.swift
//  exponea
//
//  Created by Franky on 06/07/2021.
//

import Foundation
import AnyCodable

public struct RawData: Codable {
    public let data: [String: Any]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyKey.self)
        var data: [String: Any] = [:]
        for key in container.allKeys {
            data[key.stringValue] = (try container.decode(AnyCodable.self, forKey: key)).value
        }
        self.data = data
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyKey.self)
        for key in data.keys {
            try container.encode(AnyCodable(data[key]), forKey: AnyKey(stringValue: key))
        }
    }

    struct AnyKey: CodingKey {
        var intValue: Int?

        init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }

        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }
    }
}
