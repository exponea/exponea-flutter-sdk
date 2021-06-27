//
//  RecommendationOptionsEncoder.swift
//  exponea
//
//  Created by Franky on 29/06/2021.
//

import Foundation
import ExponeaSDK

class RecommendationOptionsEncoder {
    static func decode(_ data: [String:Any?]) throws -> RecommendationOptions {
        return RecommendationOptions.init(
            id: try data.getRequired("id"),
            fillWithRandom: try data.getRequired("fillWithRandom"),
            size: Int((try data.getOptional("size") as Double?) ?? 10.0),
            items: try data.getOptional("items"),
            noTrack: try data.getOptional("noTrack") ?? false,
            catalogAttributesWhitelist:  try data.getOptional("catalogAttributesWhitelist")
        )
    }
}
