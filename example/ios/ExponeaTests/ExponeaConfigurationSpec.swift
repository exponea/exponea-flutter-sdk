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
            let integrationConfigFixtures = TestUtil.parseJsonList(TestUtil.loadFile("integration_config"))
                .map { $0 as! [String:Any?] }

            it("verify data") {
                expect(jsonList.count).to(equal(7))
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

                let settings = config.integrationConfig as! ExponeaSDK.Exponea.ProjectSettings
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

                let settings = config.integrationConfig as! ExponeaSDK.Exponea.ProjectSettings
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
                expect(config.regenerateDeviceIdOnAnonymize).to(equal(true))
            }

            it("full") {
                let data = jsonList[3]
                let config = try parser.parseConfig(data)

                let settings = config.integrationConfig as! ExponeaSDK.Exponea.ProjectSettings
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
                expect(config.regenerateDeviceIdOnAnonymize).to(equal(true))
            }

            it("normalized minimal") {
                let data = jsonList[4]
                let config = try parser.parseConfig(data)
                let settings = config.integrationConfig as! ExponeaSDK.Exponea.ProjectSettings

                expect(settings.projectToken).to(equal("mock-project-token"))
                expect(settings.authorization).to(equal(.token("mock-auth-token")))
                expect(settings.projectMapping).to(beNil())
            }

            it("normalized defaultSession") {
                let data = jsonList[5]
                let config = try parser.parseConfig(data)
                let settings = config.integrationConfig as! ExponeaSDK.Exponea.ProjectSettings

                expect(settings.projectToken).to(equal("mock-project-token"))
                expect(settings.authorization).to(equal(.token("mock-auth-token")))
                expect(settings.baseUrl).to(equal("http://mock.base.url.com"))
                // Route map entry has no baseUrl of its own, so it must use the SDK default,
                // NOT inherit the parent project's baseUrl (http://mock.base.url.com).
                expect(settings.projectMapping).to(equal([
                    EventType.banner: [
                        ExponeaSDK.ExponeaProject(
                            baseUrl: ExponeaSDK.Constants.Repository.baseUrl,
                            projectToken: "other-project-token",
                            authorization: .token("other-auth-token")
                        )
                    ]
                ]))
            }

            it("integration route map entry does not inherit parent base url") {
                let data: [String: Any?] = [
                    "integrationConfig": [
                        "projectToken": "mock-project-token",
                        "authorizationToken": "mock-auth-token",
                        "baseUrl": "https://project.example.com"
                    ],
                    "integrationRouteMap": [
                        "PAYMENT": [
                            [
                                "projectToken": "other-project-token",
                                "authorizationToken": "other-auth-token"
                            ]
                        ]
                    ]
                ]
                let config = try parser.parseConfig(data)
                let settings = config.integrationConfig as! ExponeaSDK.Exponea.ProjectSettings

                expect(settings.baseUrl).to(equal("https://project.example.com"))
                expect(settings.projectMapping).to(equal([
                    EventType.payment: [
                        ExponeaSDK.ExponeaProject(
                            baseUrl: ExponeaSDK.Constants.Repository.baseUrl,
                            projectToken: "other-project-token",
                            authorization: .token("other-auth-token")
                        )
                    ]
                ]))
            }

            it("stream integration config") {
                let data: [String: Any?] = [
                    "integrationConfig": integrationConfigFixtures[4]
                ]
                let config = try parser.parseConfig(data)
                let settings = config.integrationConfig as! ExponeaSDK.Exponea.StreamSettings

                expect(settings.streamId).to(equal("mock-stream-id"))
                expect(settings.baseUrl).to(equal("https://stream.exponea.com"))
                expect(config.advancedAuthEnabled).to(beNil())
            }

            describe("NSNull optional values") {
                func minimalConfigData(
                    iosRequirePushAuthorization: Any? = nil,
                    rootRequirePushAuthorization: Any? = nil
                ) -> [String: Any?] {
                    var data: [String: Any?] = [
                        "projectToken": "mock-project-token",
                        "authorizationToken": "mock-auth-token",
                    ]
                    if let iosRequirePushAuthorization {
                        data["ios"] = [
                            "appGroup": "mock-app-group",
                            "requirePushAuthorization": iosRequirePushAuthorization,
                        ]
                    }
                    if let rootRequirePushAuthorization {
                        data["requirePushAuthorization"] = rootRequirePushAuthorization
                    }
                    return data
                }

                it("treats ios requirePushAuthorization NSNull as absent and defaults to true") {
                    let data = minimalConfigData(iosRequirePushAuthorization: NSNull())
                    let config = try parser.parseConfig(data)

                    expect(config.pushNotificationTracking.requirePushAuthorization).to(equal(true))
                }

                it("treats root requirePushAuthorization NSNull as absent and defaults to true") {
                    let data = minimalConfigData(rootRequirePushAuthorization: NSNull())
                    let config = try parser.parseConfig(data)

                    expect(config.pushNotificationTracking.requirePushAuthorization).to(equal(true))
                }

                it("prefers ios requirePushAuthorization over root NSNull fallback") {
                    let data = minimalConfigData(
                        iosRequirePushAuthorization: false,
                        rootRequirePushAuthorization: NSNull()
                    )
                    let config = try parser.parseConfig(data)

                    expect(config.pushNotificationTracking.requirePushAuthorization).to(equal(false))
                }

                it("falls back to root value when ios requirePushAuthorization is NSNull") {
                    let data = minimalConfigData(
                        iosRequirePushAuthorization: NSNull(),
                        rootRequirePushAuthorization: false
                    )
                    let config = try parser.parseConfig(data)

                    expect(config.pushNotificationTracking.requirePushAuthorization).to(equal(false))
                }

                it("parseConfiguration treats ios requirePushAuthorization NSNull as default true") {
                    let data = minimalConfigData(iosRequirePushAuthorization: NSNull())
                    let config = try parser.parseConfig(data)
                    let nativeConfig = try parser.parseConfiguration(config, data: data)

                    expect(nativeConfig.requirePushAuthorization).to(equal(true))
                }
            }
        }

        describe("configure payload customer identity") {
            let parser = ConfigurationParser()
            let configurePayloadFixtures = TestUtil.parseJsonList(TestUtil.loadFile("configure_payload"))
                .map { $0 as! [String: Any?] }

            it("verify data") {
                expect(configurePayloadFixtures.count).to(equal(4))
            }

            it("parse absent customer identity") {
                expect(parser.parseCustomerIdentity(nil)).to(beNil())
                expect(parser.parseCustomerIdentity(configurePayloadFixtures[0]["customerIdentity"] as? [String: Any?]))
                    .to(beNil())
            }

            it("parse customer identity with jwt") {
                let identity = parser.parseCustomerIdentity(
                    configurePayloadFixtures[1]["customerIdentity"] as? [String: Any?]
                )

                expect(identity?.customerIds).to(equal(["registered": "test@mail.com"]))
                expect(identity?.jwtToken).to(equal("mock-jwt-token"))
            }

            it("parse customer identity without jwt") {
                let identity = parser.parseCustomerIdentity(
                    configurePayloadFixtures[2]["customerIdentity"] as? [String: Any?]
                )

                expect(identity?.customerIds).to(equal(["registered": "test@mail.com"]))
                expect(identity?.jwtToken).to(beNil())
            }

            it("build native sdk configuration from stream payload") {
                let payload = configurePayloadFixtures[1]
                let config = try parser.parseConfig(payload)
                let nativeConfig = try parser.parseConfiguration(config, data: payload)
                let settings = nativeConfig.integrationConfig as! ExponeaSDK.Exponea.StreamSettings

                expect(settings.streamId).to(equal("mock-stream-id"))
                expect(settings.baseUrl).to(equal("https://stream.exponea.com"))
                expect(nativeConfig.flushEventMaxRetries).to(equal(ExponeaSDK.Constants.Session.maxRetries))
            }

            it("parse configuration with ios app group and regenerateDeviceIdOnAnonymize") {
                let payload = configurePayloadFixtures[3]
                let config = try parser.parseConfig(payload)
                let nativeConfig = try parser.parseConfiguration(config, data: payload)

                expect(nativeConfig.appGroup).to(equal("group.com.exponea.sdk.example"))
                expect(nativeConfig.requirePushAuthorization).to(equal(false))
                expect(nativeConfig.tokenTrackFrequency).to(equal(.daily))
                expect(nativeConfig.regenerateDeviceIdOnAnonymize).to(equal(true))

                let identity = parser.parseCustomerIdentity(
                    payload["customerIdentity"] as? [String: Any?]
                )
                expect(identity?.jwtToken).to(equal("mock-jwt-token"))
            }
        }

        describe("identify payload") {
            let parser = ConfigurationParser()
            let identifyFixtures = TestUtil.parseJsonList(TestUtil.loadFile("identify_customer_payload"))
                .map { $0 as! [String: Any?] }

            it("parse customer identity with jwt and properties") {
                let payload = identifyFixtures[4]
                let identity = parser.parseCustomerIdentity(payload)
                let properties = try parser.parseIdentifyProperties(payload["properties"])

                expect(identity?.customerIds).to(equal(["registered": "test@mail.com"]))
                expect(identity?.jwtToken).to(equal("mock-jwt-token"))
                expect(properties["first_name"]?.jsonValue).to(equal(.string("Alice")))
            }
        }

        describe("set sdk auth token payload") {
            let tokenFixtures = TestUtil.parseJsonList(TestUtil.loadFile("set_sdk_auth_token_payload"))
                .map { $0 as! [String: Any?] }

            it("parse token payload") {
                expect(tokenFixtures[0]["token"] as? String).to(equal("mock-jwt-token"))
            }
        }

        describe("sdk auth error payload") {
            let authErrorFixtures = TestUtil.parseJsonList(TestUtil.loadFile("sdk_auth_error"))
                .map { $0 as! [String: Any?] }

            it("parse token about to expire payload") {
                expect(authErrorFixtures[0]["errorCode"] as? String).to(equal("TOKEN_ABOUT_TO_EXPIRE"))
            }

            it("parse token insufficient payload") {
                expect(authErrorFixtures[4]["errorCode"] as? String).to(equal("TOKEN_INSUFFICIENT"))
            }
        }

        describe("integration configuration change payload") {
            let parser = ConfigurationParser()
            let integrationFixtures = TestUtil.parseJsonList(TestUtil.loadFile("integration_configuration_change"))
                .map { $0 as! [String: Any?] }

            it("parse stream integration anonymize payload") {
                let change = try parser.parseConfigurationChangePayload(
                    integrationFixtures[1]
                )

                guard case .integration(let integrationConfig, let routeMap) = change else {
                    fail("Expected integration configuration change")
                    return
                }
                let integration = integrationConfig as! ExponeaSDK.ExponeaIntegration
                expect(integration.streamId).to(equal("mock-stream-id"))
                expect(routeMap).to(beNil())
            }

            it("route map entry does not inherit parent base url") {
                let data: [String: Any?] = [
                    "integrationConfig": [
                        "projectToken": "mock-project-token",
                        "authorizationToken": "mock-auth-token",
                        "baseUrl": "https://project.example.com"
                    ],
                    "integrationRouteMap": [
                        "PAYMENT": [
                            [
                                "projectToken": "other-project-token",
                                "authorizationToken": "other-auth-token"
                            ]
                        ]
                    ]
                ]
                let change = try parser.parseConfigurationChangePayload(data)

                guard case .integration(_, let routeMap) = change else {
                    fail("Expected integration configuration change")
                    return
                }
                let projects = routeMap?[EventType.payment]
                expect(projects?.count).to(equal(1))
                // Route map entry has no baseUrl, so it must fall back to the SDK default,
                // not inherit the parent project's https://project.example.com.
                expect(projects?.first?.baseUrl).to(equal(ExponeaSDK.Constants.Repository.baseUrl))
            }
        }
    }
}
