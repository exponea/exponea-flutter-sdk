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

    func parseConfigChange(_ data: [String:Any?]) throws -> ExponeaConfigurationChange {
        return try ExponeaConfigurationChange(data, parser: self)
    }

    func parseExponeaProject(
        _ projectData: [String:Any?],
        inheritBaseUrl: String? = nil
    ) throws -> ExponeaProject {
        let projectToken: String = try projectData.getRequired("projectToken")
        let authorizationToken: String = try projectData.getRequired("authorizationToken")
        if let baseUrl: String = try projectData.getOptional("baseUrl") {
            return ExponeaProject(
                baseUrl: baseUrl,
                projectToken: projectToken,
                authorization: .token(authorizationToken)
            )
        }
        if let inheritBaseUrl = inheritBaseUrl {
            return ExponeaProject(
                baseUrl: inheritBaseUrl,
                projectToken: projectToken,
                authorization: .token(authorizationToken)
            )
        }
        return ExponeaProject(
            projectToken: projectToken,
            authorization: .token(authorizationToken)
        )
    }

    func parseProjectMapping(
        _ mappingData: [String:Any?],
        inheritBaseUrl: String? = nil
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
                return try parseExponeaProject(project, inheritBaseUrl: inheritBaseUrl)
            }
            res[eventType] = exponeaProjects
        }

        return res
    }

    func parseIntegrationRouteMap(from data: [String:Any?]) throws -> [EventType: [ExponeaProject]]? {
        if data["integrationConfig"] as? [String: Any?] != nil,
           let streamId = (data["integrationConfig"] as? [String: Any?])?["streamId"] as? String,
           streamId.isEmpty == false {
            return nil
        }

        if let integrationRouteMap: [String:Any?] = try data.getOptional("integrationRouteMap") {
            // Route map entries must not inherit the parent project's baseUrl. When an entry
            // omits baseUrl it falls back to the native SDK default, not the main project's URL.
            return try parseProjectMapping(
                integrationRouteMap
            )
        }

        return nil
    }

    func parseIntegrationConfig(
        _ data: [String:Any?],
        integrationRouteMap: [EventType: [ExponeaProject]]?
    ) throws -> any IntegrationType {
        if let streamId: String = try data.getOptional("streamId") {
            if let _: String = try data.getOptional("projectToken") {
                throw ExponeaDataError.invalidValue(for: "integrationConfig")
            }
            return Exponea.StreamSettings(
                streamId: streamId,
                baseUrl: try data.getOptional("baseUrl")
            )
        }

        let projectToken: String = try data.getRequired("projectToken")
        let authorizationToken: String = try data.getRequired("authorizationToken")
        return Exponea.ProjectSettings(
            projectToken: projectToken,
            authorization: ExponeaSDK.Authorization.token(authorizationToken),
            baseUrl: try data.getOptional("baseUrl"),
            projectMapping: integrationRouteMap
        )
    }

    func parseProjectSettings(_ data: [String:Any?]) throws -> ExponeaSDK.Exponea.ProjectSettings {
        let projectToken: String = try data.getRequired("projectToken")
        let authorizationToken: String = try data.getRequired("authorizationToken")
        let explicitBaseUrl: String? = try data.getOptional("baseUrl")
        var projectMapping: [EventType: [ExponeaProject]]?
        if let mapping: [String:Any?] = try data.getOptional("projectMapping") {
            projectMapping = try parseProjectMapping(mapping, inheritBaseUrl: explicitBaseUrl)
        }
        return ExponeaSDK.Exponea.ProjectSettings(
            projectToken: projectToken,
            authorization: ExponeaSDK.Authorization.token(authorizationToken),
            baseUrl: explicitBaseUrl,
            projectMapping: projectMapping
        )
    }

    func parsePushNotificationTracking(_ data: [String:Any?]) throws -> ExponeaSDK.Exponea.PushNotificationTracking {
        let iosData: [String:Any?] = try data.getOptional("ios") ?? [:]
        let appGroup: String = try iosData.getOptional("appGroup") ?? ""
        let requirePushAuthorization: Bool = try iosData.getOptional("requirePushAuthorization") ??
            data.getOptional("requirePushAuthorization") ?? true
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

    func parseCustomerIdentity(_ data: [String: Any?]?) -> ExponeaSDK.CustomerIdentity? {
        guard let data = data else {
            return nil
        }

        var customerIds: [String: String] = [:]
        if let ids = data["customerIds"] as? [String: Any?] {
            for (key, value) in ids {
                customerIds[key] = value as? String ?? String(describing: value ?? "")
            }
        }
        let jwtToken = data["sdkAuthToken"] as? String
        return ExponeaSDK.CustomerIdentity(customerIds: customerIds, jwtToken: jwtToken)
    }

    /// Builds a native `Configuration` for `Exponea.configure(with:authContext:)`.
    func parseConfiguration(
        _ config: ExponeaConfiguration,
        data: [String: Any?]
    ) throws -> ExponeaSDK.Configuration {
        let iosData: [String: Any?] = try data.getOptional("ios") ?? [:]
        let appGroup: String = try iosData.getOptional("appGroup") ?? ""
        let requirePushAuthorization: Bool = try iosData.getOptional("requirePushAuthorization") ??
            data.getOptional("requirePushAuthorization") ?? true
        var tokenTrackFrequency: TokenTrackFrequency?
        if let frequencyString: String = try data.getOptional("pushTokenTrackingFrequency") {
            switch frequencyString {
            case "ON_TOKEN_CHANGE": tokenTrackFrequency = .onTokenChange
            case "EVERY_LAUNCH": tokenTrackFrequency = .everyLaunch
            case "DAILY": tokenTrackFrequency = .daily
            default: throw ExponeaDataError.invalidValue(for: "pushTokenTrackingFrequency")
            }
        }

        let automaticSessionTracking: Bool = try data.getOptional("automaticSessionTracking") ?? true
        let sessionTimeout: Double = try data.getOptional("sessionTimeout") ??
            ExponeaSDK.Constants.Session.defaultTimeout
        let flushMaxRetries: Int = try data.getOptional("flushMaxRetries") ??
            ExponeaSDK.Constants.Session.maxRetries

        return try ExponeaSDK.Configuration(
            integrationConfig: config.integrationConfig,
            appGroup: appGroup,
            defaultProperties: config.defaultProperties,
            inAppContentBlocksPlaceholders: config.inAppContentBlockPlaceholdersAutoLoad,
            sessionTimeout: sessionTimeout,
            automaticSessionTracking: automaticSessionTracking,
            automaticPushNotificationTracking: false,
            requirePushAuthorization: requirePushAuthorization,
            tokenTrackFrequency: tokenTrackFrequency,
            flushEventMaxRetries: flushMaxRetries,
            allowDefaultCustomerProperties: config.allowDefaultCustomerProperties ?? true,
            advancedAuthEnabled: config.advancedAuthEnabled,
            manualSessionAutoClose: config.manualSessionAutoClose,
            applicationID: config.applicationId,
            regenerateDeviceIdOnAnonymize: config.regenerateDeviceIdOnAnonymize ?? false
        )
    }
}

enum ParsedConfigurationChange {
    case legacy(ExponeaConfigurationChange)
    case integration(
        integrationConfig: any ExponeaSDK.ExponeaIntegrationType,
        integrationRouteMap: [EventType: [ExponeaProject]]?
    )
}

extension ConfigurationParser {
    func parseConfigurationChangePayload(
        _ data: [String: Any?]
    ) throws -> ParsedConfigurationChange {
        if data["integrationConfig"] != nil {
            guard let integrationConfigData = data["integrationConfig"] as? [String: Any?] else {
                throw ExponeaDataError.invalidType(for: "integrationConfig")
            }
            let integrationConfig = try parseIntegrationConfig(
                integrationConfigData,
                integrationRouteMap: nil
            )
            var integrationRouteMap: [EventType: [ExponeaProject]]?
            if let routeMapData = data["integrationRouteMap"] as? [String: Any?] {
                // Route map entries must not inherit the parent project's baseUrl. When an entry
                // omits baseUrl it falls back to the native SDK default, not the main project's URL.
                integrationRouteMap = try parseProjectMapping(
                    routeMapData
                )
            }
            return .integration(
                integrationConfig: try toExponeaIntegrationType(integrationConfig),
                integrationRouteMap: integrationRouteMap
            )
        }

        return .legacy(try parseConfigChange(data))
    }

    func parseIdentifyProperties(_ data: Any?) throws -> [String: JSONConvertible] {
        guard let properties = data as? [String: Any] else {
            return [:]
        }
        return try properties.mapValues { value in
            try JsonDataParser.parseValue(value: value)
        }
    }

    private func toExponeaIntegrationType(
        _ integrationConfig: any IntegrationType
    ) throws -> any ExponeaSDK.ExponeaIntegrationType {
        if let streamSettings = integrationConfig as? ExponeaSDK.Exponea.StreamSettings {
            return ExponeaSDK.ExponeaIntegration(
                baseUrl: streamSettings.baseUrl,
                streamId: streamSettings.streamId
            )
        }
        if let projectSettings = integrationConfig as? ExponeaSDK.Exponea.ProjectSettings {
            return ExponeaSDK.ExponeaProject(
                baseUrl: projectSettings.baseUrl,
                projectToken: projectSettings.projectToken,
                authorization: projectSettings.authorization
            )
        }
        throw ExponeaDataError.invalidValue(for: "integrationConfig")
    }
}
