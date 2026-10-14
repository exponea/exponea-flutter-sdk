//
//  RecommendationSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class RecommendationOptionsSpec: QuickSpec {
    override func spec() {
        describe("encode") {
            let fileData = TestUtil.loadFile("recommendation_options")
            let jsonList = TestUtil.parseJsonList(fileData)
            
            it("verify data") {
                expect(jsonList.count).to(equal(4))
            }
            
            it("decode empty map") {
                let data = jsonList[0] as! [String:Any?]
                do {
                    _ = try RecommendationOptionsEncoder.decode(data)
                    fail("Should throw error")
                } catch {
                    expect(error.localizedDescription).to(equal("Property id is required."))
                }
            }
            
            it("decode missing fillWithRandom") {
                let data = jsonList[1] as! [String:Any?]
                do {
                    _ = try RecommendationOptionsEncoder.decode(data)
                    fail("Should throw error")
                } catch {
                    expect(error.localizedDescription).to(equal("Property fillWithRandom is required."))
                }
            }
            
            it("min") {
                let data = jsonList[2] as! [String:Any?]
                
                let expected = RecommendationOptions.init(id: "mock-id", fillWithRandom: true)
                let decoded = try RecommendationOptionsEncoder.decode(data)

                expect(decoded.id).to(equal(expected.id))
                expect(decoded.fillWithRandom).to(equal(expected.fillWithRandom))
                expect(decoded.size).to(equal(expected.size))
                expect(decoded.items).to(beNil())
                expect(decoded.noTrack).to(equal(expected.noTrack))
                expect(decoded.catalogAttributesWhitelist).to(beNil())
            }
            
            it("full") {
                let data = jsonList[3] as! [String:Any?]
                
                let expected = RecommendationOptions.init(
                    id: "mock-id",
                    fillWithRandom: false,
                    size: 5,
                    items: ["a": "b", "c": "d"],
                    noTrack: true,
                    catalogAttributesWhitelist: ["1", "test", "...mock"]
                )
                let decoded = try RecommendationOptionsEncoder.decode(data)

                expect(decoded.id).to(equal(expected.id))
                expect(decoded.fillWithRandom).to(equal(expected.fillWithRandom))
                expect(decoded.size).to(equal(expected.size))
                expect(decoded.items).to(equal(expected.items))
                expect(decoded.noTrack).to(equal(expected.noTrack))
                expect(decoded.catalogAttributesWhitelist).to(equal(expected.catalogAttributesWhitelist))
            }
        }
    }
}
