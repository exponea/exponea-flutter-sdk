//
//  ExponeaConfigurationParserSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class ExponeaConfigurationParserSpec: QuickSpec {
    override func spec() {
        describe("parse") {
            let parser = ConfigurationParser()
            let fileData = TestUtil.loadFile("configuration")
            let jsonList = TestUtil.parseJsonList(fileData).map { $0 as! [String:Any?] }
            
            it("verify data") {
                expect(jsonList.count).to(equal(4))
            }
            
            it("emoty map") {
                let data = jsonList[0]
                do {
                    _ = try parser.parseConfig(data)
                    fail("Should throw error")
                } catch {
                    expect(error.localizedDescription).to(equal("Property projectToken is required."))
                }
            }
            
            it("minimal") {
                let data = jsonList[1]
                let config = try parser.parseConfig(data)
                
                let settings = config.projectSettings
                expect(settings.projectToken).to(equal("mock-project-token"))
                expect(settings.authorization).to(equal(.token("mock-auth-token")))
                expect(settings.baseUrl).to(equal(ExponeaSDK.Constants.Repository.baseUrl))
                
                let setup = config.flushingSetup
                expect(setup.maxRetries).to(equal(ExponeaSDK.Constants.Session.maxRetries))
                
                let sessionTracking = config.automaticSessionTracking
                expect(sessionTracking.enabled).to(equal(true))
                expect(sessionTracking.timeout).to(equal(ExponeaSDK.Constants.Session.defaultTimeout))
                
                let props = config.defaultProperties
                expect(props).to(beNil())
                
                let notifTracking = config.pushNotificationTracking
                expect(notifTracking.appGroup).to(equal(""))
                expect(notifTracking.requirePushAuthorization).to(equal(true))
                expect(notifTracking.isEnabled).to(equal(true))
                
                expect(config.allowDefaultCustomerProperties).to(beNil())
            }
            
            it("defaultSession") {
                let data = jsonList[2]
                let config = try parser.parseConfig(data)

                let settings = config.projectSettings
                expect(settings.projectToken).to(equal("mock-project-token"))
                expect(settings.authorization).to(equal(.token("mock-auth-token")))
                expect(settings.baseUrl).to(equal("http://mock.base.url.com"))
                expect(settings.projectMapping).to(equal([
                    EventType.banner: [
                        ExponeaSDK.ExponeaProject(
                            baseUrl: settings.baseUrl,
                            projectToken: "other-project-token",
                            authorization: .token("other-auth-token")
                        )
                    ]
                ]))

                let setup = config.flushingSetup
                expect(setup.maxRetries).to(equal(10))

                let sessionTracking = config.automaticSessionTracking
                expect(sessionTracking.enabled).to(equal(true))
                expect(sessionTracking.timeout).to(equal(60))

                let props = config.defaultProperties
                expect(props).notTo(beNil())
                let propsF = props!
                expect(propsF["string"]?.jsonValue).to(equal(.string("value")))
                expect(propsF["boolean"]?.jsonValue).to(equal(.bool(false)))
                expect(propsF["number"]?.jsonValue).to(equal(.double(3.14159)))
                expect(propsF["array"]?.jsonValue).to(equal(.array([.string("value1"), .string("value2")])))
                expect(propsF["object"]?.jsonValue).to(equal(.dictionary(["key": .string("value")])))

                let notifTracking = config.pushNotificationTracking
                expect(notifTracking.isEnabled).to(equal(true))
                expect(notifTracking.tokenTrackFrequency).to(equal(.daily))
                expect(notifTracking.appGroup).to(equal("mock-app-group"))
                expect(notifTracking.requirePushAuthorization).to(equal(false))
                expect(notifTracking.delegate).to(beNil())

                expect(config.allowDefaultCustomerProperties).to(equal(true))
            }

            it("full") {
                let data = jsonList[3]
                let config = try parser.parseConfig(data)
                
                let settings = config.projectSettings
                expect(settings.projectToken).to(equal("mock-project-token"))
                expect(settings.authorization).to(equal(.token("mock-auth-token")))
                expect(settings.baseUrl).to(equal("http://mock.base.url.com"))
                expect(settings.projectMapping).to(equal([
                    EventType.banner: [
                        ExponeaSDK.ExponeaProject(
                            baseUrl: settings.baseUrl,
                            projectToken: "other-project-token",
                            authorization: .token("other-auth-token")
                        )
                    ]
                ]))
                
                let setup = config.flushingSetup
                expect(setup.maxRetries).to(equal(10))
                
                let sessionTracking = config.automaticSessionTracking
                expect(sessionTracking.enabled).to(equal(true))
                expect(sessionTracking.timeout).to(equal(45))
                
                let props = config.defaultProperties
                expect(props).notTo(beNil())
                let propsF = props!
                expect(propsF["string"]?.jsonValue).to(equal(.string("value")))
                expect(propsF["boolean"]?.jsonValue).to(equal(.bool(false)))
                expect(propsF["number"]?.jsonValue).to(equal(.double(3.14159)))
                expect(propsF["array"]?.jsonValue).to(equal(.array([.string("value1"), .string("value2")])))
                expect(propsF["object"]?.jsonValue).to(equal(.dictionary(["key": .string("value")])))
                
                let notifTracking = config.pushNotificationTracking
                expect(notifTracking.isEnabled).to(equal(true))
                expect(notifTracking.tokenTrackFrequency).to(equal(.daily))
                expect(notifTracking.appGroup).to(equal("mock-app-group"))
                expect(notifTracking.requirePushAuthorization).to(equal(false))
                expect(notifTracking.delegate).to(beNil())
                
                expect(config.allowDefaultCustomerProperties).to(equal(true))
            }
        }
    }
}
