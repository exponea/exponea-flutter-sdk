//
//  NSDictionaryGetSafelySpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import exponea

class NSDictionaryGetSafelySpec: QuickSpec {
    override func spec() {
        describe("getOptionalSafely") {
            it("returns nil for NSNull value") {
                let dict: NSDictionary = ["key": NSNull()]
                let value: String? = try dict.getOptionalSafely(property: "key")
                expect(value).to(beNil())
            }

            it("returns nil for missing key") {
                let dict: NSDictionary = [:]
                let value: String? = try dict.getOptionalSafely(property: "key")
                expect(value).to(beNil())
            }

            it("returns value when present") {
                let dict: NSDictionary = ["key": "value"]
                let value: String? = try dict.getOptionalSafely(property: "key")
                expect(value).to(equal("value"))
            }

            it("throws invalidType for wrong type") {
                let dict: NSDictionary = ["key": 123]
                do {
                    let _: String? = try dict.getOptionalSafely(property: "key")
                    fail("expected invalidType error")
                } catch let error as ExponeaDataError {
                    if case .invalidType(let property) = error {
                        expect(property).to(equal("key"))
                    } else {
                        fail("expected invalidType, got \(error)")
                    }
                }
            }
        }

        describe("getRequiredSafely") {
            it("throws missingProperty for NSNull value") {
                let dict: NSDictionary = ["key": NSNull()]
                do {
                    let _: String = try dict.getRequiredSafely(property: "key")
                    fail("expected missingProperty error")
                } catch let error as ExponeaDataError {
                    if case .missingProperty(let property) = error {
                        expect(property).to(equal("key"))
                    } else {
                        fail("expected missingProperty, got \(error)")
                    }
                }
            }

            it("throws missingProperty for missing key") {
                let dict: NSDictionary = [:]
                do {
                    let _: String = try dict.getRequiredSafely(property: "key")
                    fail("expected missingProperty error")
                } catch let error as ExponeaDataError {
                    if case .missingProperty(let property) = error {
                        expect(property).to(equal("key"))
                    } else {
                        fail("expected missingProperty, got \(error)")
                    }
                }
            }

            it("returns value when present") {
                let dict: NSDictionary = ["key": "value"]
                let value: String = try dict.getRequiredSafely(property: "key")
                expect(value).to(equal("value"))
            }

            it("throws invalidType for wrong type") {
                let dict: NSDictionary = ["key": 123]
                do {
                    let _: String = try dict.getRequiredSafely(property: "key")
                    fail("expected invalidType error")
                } catch let error as ExponeaDataError {
                    if case .invalidType(let property) = error {
                        expect(property).to(equal("key"))
                    } else {
                        fail("expected invalidType, got \(error)")
                    }
                }
            }
        }

        describe("App Inbox action parsing") {
            it("parses action NSDictionary with NSNull optional fields without throwing") {
                let actionData: NSDictionary = [
                    "action": "open",
                    "title": NSNull(),
                    "url": NSNull(),
                ]

                let action: String? = try actionData.getOptionalSafely(property: "action")
                let title: String? = try actionData.getOptionalSafely(property: "title")
                let url: String? = try actionData.getOptionalSafely(property: "url")

                expect(action).to(equal("open"))
                expect(title).to(beNil())
                expect(url).to(beNil())
            }
        }
    }
}

