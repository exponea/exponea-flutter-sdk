//
//  ConsentSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class ConsentSpec: QuickSpec {
    override func spec() {
        describe("encode") {
            let fileData = TestUtil.loadFile("consent")
            let jsonList = TestUtil.parseJsonList(fileData)
            
            it("verify data") {
                expect(jsonList.count).to(equal(4))
            }
            
            it("min") {
                let data = jsonList[2] as! [String:Any?]
                
                let consent = Consent.init(
                    id: "mock-id",
                    legitimateInterest: true,
                    sources: ConsentSources.init(
                        isCreatedFromCRM: false,
                        isImported: true,
                        isFromConsentPage: false,
                        privateAPI: true,
                        publicAPI: false,
                        isTrackedFromScenario: true
                    ),
                    translations: [:]
                )
                let encoded = ConsentEncoder.encode(consent)

                expect(try TestUtil.dictToJsonString(encoded)).to(equal(try TestUtil.dictToJsonString(data)))
            }
            
            it("full") {
                let data = jsonList[3] as! [String:Any?]
                
                let consent = Consent.init(
                    id: "mock-id",
                    legitimateInterest: true,
                    sources: ConsentSources.init(
                        isCreatedFromCRM: false,
                        isImported: true,
                        isFromConsentPage: false,
                        privateAPI: true,
                        publicAPI: false,
                        isTrackedFromScenario: true
                    ),
                    translations: ["cz":["desc":"","test":"aaaa"]]
                )
                let encoded = ConsentEncoder.encode(consent)
                
                expect(try TestUtil.dictToJsonString(encoded)).to(equal(try TestUtil.dictToJsonString(data)))
            }
        }
    }
}
