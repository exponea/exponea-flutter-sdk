//
//  TestUtil.swift
//  Tests
//

import Foundation
import Quick

private final class TestBundleLocator {}

struct TestUtil {
    static func loadFile(_ fileName: String) -> String {
        let bundle = Bundle(for: TestBundleLocator.self)
        guard let url = bundle.url(forResource: fileName, withExtension: "json", subdirectory: "values") else {
            XCTFail("Missing fixture: \(fileName).json in test bundle")
            return ""
        }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            XCTFail(error.localizedDescription)
            return ""
        }
    }

    static func parseJson(_ jsonString: String) -> [String:Any?] {
        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Unable to read data")
            return [:]
        }
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any?] else {
            XCTFail("Unable to parse data")
            return [:]
        }
        return dictionary
    }
    
    static func parseJsonList(_ jsonString: String) -> [Any] {
        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Unable to read data")
            return []
        }
        guard let list = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
            XCTFail("Unable to parse data")
            return []
        }
        return list
    }

    static func getSortedKeysJson(_ jsonString: String) -> String {
        guard
            let jsonData = jsonString.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
            let sortedJsonData = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.sortedKeys]
            ),
            let jsonString = String(data: sortedJsonData, encoding: .utf8) else {
            XCTFail("Unable to parse consents response")
            return ""
        }
        return jsonString
    }

    static func dictToJsonString(_ data: [String:Any?]) throws -> String? {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [.sortedKeys])
        return String(data: jsonData, encoding: .utf8)
    }
}
