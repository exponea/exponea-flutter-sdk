//
//  JsonDataParserSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class JsonDataParserSpec: QuickSpec {
    override func spec() {
        it("should parse string") {
            let json = TestUtil.parseJson("{\"key\": \"string value\"}")
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["key"]?.jsonValue).to(equal(.string("string value")))
        }
        it("should parse real number") {
            let json = TestUtil.parseJson("{\"key\": 123.456}")
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["key"]?.jsonValue).to(equal(.double(123.456)))
        }
        it("should parse 0") {
            let json = TestUtil.parseJson("{\"key\": 0}")
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["key"]?.jsonValue).to(equal(.double(0.0)))
        }
        it("should parse 1") {
            let json = TestUtil.parseJson("{\"key\": 1}")
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["key"]?.jsonValue).to(equal(.double(1.0)))
        }
        it("should parse true") {
            let json = TestUtil.parseJson("{\"key\": true}")
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["key"]?.jsonValue).to(equal(.bool(true)))
        }
        it("should parse false") {
            let json = TestUtil.parseJson("{\"key\": false}")
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["key"]?.jsonValue).to(equal(.bool(false)))
        }
        it("should parse number array") {
            let json = TestUtil.parseJson("{\"key\": [1,2,3]}")
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["key"]?.jsonValue).to(equal(.array([.double(1), .double(2), .double(3)])))
        }
        it("should parse mixed array") {
            let json = TestUtil.parseJson("{\"key\": [1,\"string\",false]}")
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["key"]?.jsonValue).to(equal(.array([.double(1), .string("string"), .bool(false)])))
        }
        it("should parse object") {
            let json = TestUtil.parseJson("{\"key\": {\"another_key\": \"string\"}}")
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["key"]?.jsonValue).to(equal(.dictionary(["another_key": .string("string")])))
        }
        it("should parse complex json") {
            let json = TestUtil.parseJson("""
                {
                  "object": {
                    "key": [
                        [
                            "string",
                            false,
                            123,
                            {"otherObject": {"otherKey": true}}
                        ]
                    ]
                  }
                }
            """)
            let data = try? JsonDataParser.parse(dictionary: json)
            expect(data?["object"]?.jsonValue).to(equal(
                .dictionary([
                    "key": .array([
                        .array([
                            .string("string"),
                            .bool(false),
                            .double(123.0),
                            .dictionary([
                                "otherObject": .dictionary([
                                    "otherKey": .bool(true)
                                ])
                            ])
                        ])
                    ])
                ]))
            )
        }
    }
}
