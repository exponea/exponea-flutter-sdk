//
//  ExponeaConfigurationChangeSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class ExponeaConfigurationChangeSpec: QuickSpec {
    override func spec() {
        describe("parse") {
            let parser = ConfigurationParser()
            let fileData = TestUtil.loadFile("configuration_change")
            let jsonList = TestUtil.parseJsonList(fileData).map { $0 as! [String:Any?] }
            let defaultBaseUrl = "DDD"
            
            it("verify data") {
                expect(jsonList.count).to(equal(4))
            }
            
            it("emoty map") {
                let data = jsonList[0]
                let change = try parser.parseConfigChange(data, defaultBaseUrl: defaultBaseUrl)

                expect(change.project).to(beNil())
                expect(change.mapping).to(beNil())
            }
            
            it("minimal") {
                let data = jsonList[1]
                let change = try parser.parseConfigChange(data, defaultBaseUrl: defaultBaseUrl)
                
                expect(change.project).notTo(beNil())
                let project = change.project!
                expect(project.projectToken).to(equal("mock-project-token"))
                expect(project.authorization).to(equal(.token("mock-auth-token")))
                expect(project.baseUrl).to(equal(defaultBaseUrl))
                expect(change.mapping).to(beNil())
            }
            
            it("minimal with base url") {
                let data = jsonList[2]
                let change = try parser.parseConfigChange(data, defaultBaseUrl: defaultBaseUrl)
                
                expect(change.project).notTo(beNil())
                let project = change.project!
                expect(project.projectToken).to(equal("mock-project-token"))
                expect(project.authorization).to(equal(.token("mock-auth-token")))
                expect(project.baseUrl).to(equal("http://mock.base.url.com"))
                expect(change.mapping).to(beNil())
            }
            
            it("full") {
                let data = jsonList[3]
                let change = try parser.parseConfigChange(data, defaultBaseUrl: defaultBaseUrl)
                
                expect(change.project).notTo(beNil())
                let project = change.project!
                expect(project.projectToken).to(equal("mock-project-token"))
                expect(project.authorization).to(equal(.token("mock-auth-token")))
                expect(project.baseUrl).to(equal("http://mock.base.url.com"))
                expect(change.mapping).to(equal([
                    EventType.payment: [
                        ExponeaSDK.ExponeaProject(
                            baseUrl: project.baseUrl,
                            projectToken: "other-project-token",
                            authorization: .token("other-auth-token")
                        )
                    ]
                ]))
            }
        }
    }
}
