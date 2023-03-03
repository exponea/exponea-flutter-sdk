//
//  AppInboxCoder.swift
//  exponea
//
//  Created by Adam Mihalik on 03/03/2023.
//

import Foundation
import ExponeaSDK

class AppInboxCoder {
    static func encode(_ source: MessageItem) throws -> [String:Any?] {
        // keep in sync with app_inbox.dart
        return [
            "id": source.id,
            "type": source.type,
            "isRead": source.read,
            "createTime": source.rawReceivedTime,
            "content": try self.normalizeData(source.rawContent)
        ]
    }
    
    private static func normalizeData(_ source: [String: JSONValue]?) throws -> [String: Any?] {
        let rawContent = try JSONEncoder().encode(source)
        let normalized = try JSONSerialization.jsonObject(
            with: rawContent, options: []
        ) as? [String: Any?]
        return normalized ?? [:]
    }
}
