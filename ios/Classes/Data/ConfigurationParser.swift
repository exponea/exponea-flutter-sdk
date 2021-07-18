//
//  ConfigurationParser.swift
//  Exponea
//

import Foundation
import ExponeaSDK

class ConfigurationParser {
    func parseConfig(_ data: [String:Any?]) throws -> ExponeaConfiguration {
        return try ExponeaConfiguration(data, parser: self)
    }

    func parseConfigChange(_ data: [String:Any?], defaultBaseUrl: String) throws -> ExponeaConfigurationChange {
        return try ExponeaConfigurationChange(data, parser: self, baseUrl: defaultBaseUrl)
    }

    func parseExponeaProject(_ projectData: [String:Any?], defaultBaseUrl: String) throws -> ExponeaProject {
        let projectToken: String = try projectData.getRequired("projectToken")
        let authorizationToken: String = try projectData.getRequired("authorizationToken")
        let baseUrl: String = try projectData.getOptional("baseUrl") ?? defaultBaseUrl
        return ExponeaProject(baseUrl: baseUrl, projectToken: projectToken, authorization: .token(authorizationToken))
    }

    func parseProjectMapping(
        _ mappingData: [String:Any?],
        defaultBaseUrl: String
    ) throws -> [EventType: [ExponeaProject]] {
        var res: [EventType: [ExponeaProject]]  = [:]

        for (key, value) in mappingData {
            guard let eventType = EventType(rawValue: key) else {
                throw ExponeaDataError.invalidValue(for: "eventType key")
            }
            guard let projectArray = value as? [Any] else {
                continue // skip empty values
            }
            let exponeaProjects: [ExponeaProject] = try projectArray.map { project in
                guard let project = project as? [String:Any?] else {
                    throw ExponeaDataError.invalidType(for: "project in project list in project mapping")
                }
                return try parseExponeaProject(project, defaultBaseUrl: defaultBaseUrl)
            }
            res[eventType] = exponeaProjects
        }

        return res
    }

    func parseProjectSettings(_ data: [String:Any?]) throws -> ExponeaSDK.Exponea.ProjectSettings {
        let projectToken: String = try data.getRequired("projectToken")
        let authorizationToken: String = try data.getRequired("authorizationToken")
        let baseUrl: String = try data.getOptional("baseUrl") ?? ExponeaSDK.Constants.Repository.baseUrl
        var projectMapping: [EventType: [ExponeaProject]]?
        if let mapping: [String:Any?] = try data.getOptional("projectMapping") {
            projectMapping = try parseProjectMapping(mapping, defaultBaseUrl: baseUrl)
        }
        return ExponeaSDK.Exponea.ProjectSettings(
            projectToken: projectToken,
            authorization: ExponeaSDK.Authorization.token(authorizationToken),
            baseUrl: baseUrl,
            projectMapping: projectMapping
        )
    }

    func parsePushNotificationTracking(_ data: [String:Any?]) throws -> ExponeaSDK.Exponea.PushNotificationTracking {
        let iosData: [String:Any?] = try data.getOptional("ios") ?? [:]
        let appGroup: String = try iosData.getOptional("appGroup") ?? ""
        let requirePushAuthorization: Bool = try iosData.getOptional("requirePushAuthorization") ?? true
        var frequency: TokenTrackFrequency?
        if let frequencyString: String = try data.getOptional("pushTokenTrackingFrequency") {
            switch frequencyString {
            case "ON_TOKEN_CHANGE": frequency = .onTokenChange
            case "EVERY_LAUNCH": frequency = .everyLaunch
            case "DAILY": frequency = .daily
            default: throw ExponeaDataError.invalidValue(for: "pushTokenTrackingFrequency")
            }
        }

        if let frequency = frequency {
            return ExponeaSDK.Exponea.PushNotificationTracking.enabled(
                appGroup: appGroup,
                requirePushAuthorization: requirePushAuthorization,
                tokenTrackFrequency: frequency
            )
        } else {
            return ExponeaSDK.Exponea.PushNotificationTracking.enabled(
                appGroup: appGroup,
                requirePushAuthorization: requirePushAuthorization
            )
        }
    }

    func parseSessionTracking(_ data: [String:Any?]) throws -> ExponeaSDK.Exponea.AutomaticSessionTracking {
        let automaticSessionTracking: Bool = try data.getOptional("automaticSessionTracking") ?? true
        let timeout: Double = try data.getOptional("sessionTimeout") ?? ExponeaSDK.Constants.Session.defaultTimeout
        return automaticSessionTracking ? .enabled(timeout: timeout) : .disabled
    }

    func parseDefaultProperties(_ data: [String:Any?]) throws -> [String: JSONConvertible]? {
        if let props: [String:Any?] = try data.getOptional("defaultProperties") {
            return try JsonDataParser.parse(dictionary: props)
        }
        return nil
    }

    func parseFlushingSetup(_ data: [String:Any?]) throws -> ExponeaSDK.Exponea.FlushingSetup {
        let maxRetries: Int = try data.getOptional("flushMaxRetries") ?? ExponeaSDK.Constants.Session.maxRetries
        return ExponeaSDK.Exponea.FlushingSetup(mode: .immediate, maxRetries: maxRetries)
    }

}
