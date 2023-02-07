//
//  ExponeaConfiguration.swift
//  exponea
//
//  Created by Franky on 16/06/2021.
//

import Foundation
import ExponeaSDK

class ExponeaConfiguration {
    let projectSettings: ExponeaSDK.Exponea.ProjectSettings
    let pushNotificationTracking: ExponeaSDK.Exponea.PushNotificationTracking
    let automaticSessionTracking: ExponeaSDK.Exponea.AutomaticSessionTracking
    let flushingSetup: ExponeaSDK.Exponea.FlushingSetup
    let defaultProperties: [String: JSONConvertible]?
    let allowDefaultCustomerProperties: Bool?
    
    init(_ data: [String:Any?], parser: ConfigurationParser) throws {
        self.projectSettings = try parser.parseProjectSettings(data)
        self.pushNotificationTracking = try parser.parsePushNotificationTracking(data)
        self.automaticSessionTracking = try parser.parseSessionTracking(data)
        self.flushingSetup = try parser.parseFlushingSetup(data)
        self.defaultProperties = try parser.parseDefaultProperties(data)
        if let allowDefaultCustomerProperties = data["allowDefaultCustomerProperties"] as? Bool {
            self.allowDefaultCustomerProperties = allowDefaultCustomerProperties
        } else {
            self.allowDefaultCustomerProperties = nil
        }
    }
}
