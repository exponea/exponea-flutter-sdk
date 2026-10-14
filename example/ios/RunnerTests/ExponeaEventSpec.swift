//
//  ExponeaEventSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class ExponeaEventSpec: QuickSpec {
    override func spec() {
        describe("parse") {
            let fileData = TestUtil.loadFile("event")
            let jsonList = TestUtil.parseJsonList(fileData).map { $0 as! [String:Any?] }
            
            it("verify data") {
                expect(jsonList.count).to(equal(4))
            }
            
            it("empty map") {
                let data = jsonList[0]
                do {
                    _ = try ExponeaEvent(data)
                    fail("Should throw error")
                } catch {
                    expect(error.localizedDescription).to(equal("Property name is required."))
                }
            }
            
            it("event with name only") {
                let data = jsonList[1]
                let event = try ExponeaEvent(data)

                expect(event.name).to(equal("test_event"))
                expect(event.properties.isEmpty).to(equal(true))
                expect(event.timestamp).to(beNil())
            }
            
            it("event with empty values") {
                let data = jsonList[2]
                let event = try ExponeaEvent(data)
                
                expect(event.name).to(equal("test_event"))
                expect(event.properties.isEmpty).to(equal(true))
                expect(event.timestamp).to(beNil())
            }
            
            it("full event") {
                let data = jsonList[3]
                let event = try ExponeaEvent(data)
                
                expect(event.name).to(equal("test_event"))
                expect(event.properties.count).to(equal(4))
                expect(event.properties["str_test"]?.jsonValue).to(equal(.string("abc-123")))
                expect(event.properties["double_test"]?.jsonValue).to(equal(.double(123.987)))
                expect(event.properties["bool_test"]?.jsonValue).to(equal(.bool(true)))
                expect(event.properties["int_test"]?.jsonValue).to(equal(.double(109.0)))
                expect(event.timestamp).to(equal(1234567890.0))
            }
        }
    }
}
