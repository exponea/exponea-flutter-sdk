//
//  PurchasedItemCoder.swift
//  exponea
//

import Foundation
import ExponeaSDK


class PurchasedItemCoder {
    static func mapProperties(_ source: [String:Any?]) throws -> [String: JSONConvertible] {
        var data : [String:Any?] = [
            "brutto": try source.getRequired("value"),
            "currency": try source.getRequired("currency"),
            "payment_system": try source.getRequired("paymentSystem"),
            "item_id": try source.getRequired("productId"),
            "product_title": try source.getRequired("productTitle"),
        ]
        if let receipt: String = try source.getOptional("receipt") {
            data["receipt"] = receipt
        }
        let source = try JsonDataParser.parse(dictionary: data)
        let jsonSource = JSONValue.convert(source)
        let properties: [String: JSONConvertible] = jsonSource.mapValues { val in
            val.jsonConvertible
        }
        return properties
    }
}
