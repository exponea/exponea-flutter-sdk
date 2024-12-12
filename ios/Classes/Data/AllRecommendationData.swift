//
//  AllRecommendationData.swift
//  exponea
//

import Foundation
import ExponeaSDK
import AnyCodable

public struct AllRecommendationData: RecommendationUserData {
    public let data: [String: Any]
    
    public func formattedData() throws -> [String: Any?] {
        var localData = [String:Any?]()
        for (key,value) in data {
            localData[key] = value
        }
        return [
            "engineName": localData.removeValue(forKey: "engine_name"),
            "itemId": localData.removeValue(forKey: "item_id"),
            "recommendationId": localData.removeValue(forKey: "recommendation_id"),
            "recommendationVariantId": localData.removeValue(forKey: "recommendation_variant_id"),
            "data": try String(data: JSONSerialization.data(withJSONObject: localData), encoding: .utf8),
        ]
    }

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

    public static func == (lhs: AllRecommendationData, rhs: AllRecommendationData) -> Bool {
        return AnyCodable(lhs.data) == AnyCodable(rhs.data)
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
