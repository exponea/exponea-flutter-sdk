//
//  ReceivedPush.swift
//  exponea
//

import Foundation

class ReceivedPush {
    let data: [String:Any]

    init(data: [String:Any]) {
        self.data = data
    }

    init(_ data: [String:Any?]) throws {
        self.data = try data.getRequired("data")
    }

    func toMap() -> [String:Any?] {
        return [
            "data": self.data,
        ]
    }
}
