import Flutter
import UIKit
import ExponeaSDK
import UserNotifications
import Foundation

private let channelName = "com.exponea"
private let openedPushStreamName = "\(channelName)/opened_push"
private let receivedPushStreamName = "\(channelName)/received_push"
private let methodConfigure = "configure"
private let methodIsConfigured = "isConfigured"
private let methodGetCustomerCookie = "getCustomerCookie"
private let methodIdentifyCustomer = "identifyCustomer"
private let methodAnonymize = "anonymize"
private let methodGetDefaultProperties = "getDefaultProperties"
private let methodSetDefaultProperties = "setDefaultProperties"
private let methodFlush = "flush"
private let methodGetFlushMode = "getFlushMode"
private let methodSetFlushMode = "setFlushMode"
private let methodGetFlushPeriod = "getFlushPeriod"
private let methodSetFlushPeriod = "setFlushPeriod"
private let methodTrackEvent = "trackEvent"
private let methodTrackSessionStart = "trackSessionStart"
private let methodTrackSessionEnd = "trackSessionEnd"
private let methodFetchConsents = "fetchConsents"
private let methodFetchRecommendations = "fetchRecommendations"
private let methodGetLogLevel = "getLogLevel"
private let methodSetLogLevel = "setLogLevel"
private let methodCheckPushSetup = "checkPushSetup"
private let methodRequestPushAuthorization = "requestPushAuthorization"


private let defaultFlushPeriod = 5 * 60 // 5 minutes

private let errorCode = "ExponeaPlugin"

// This protocol is queried using reflection by native iOS SDK to see if it's run by Flutter SDK
@objc(IsExponeaFlutterSDK)
protocol IsExponeaFlutterSDK {
}

@objc(ExponeaFlutterVersion)
public class ExponeaFlutterVersion: NSObject, ExponeaVersionProvider {
    required public override init() { }
    public func getVersion() -> String {
        "1.1.0"
    }
}

public class SwiftExponeaPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftExponeaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let openedPushEventChannel = FlutterEventChannel(name: openedPushStreamName, binaryMessenger: registrar.messenger())
        openedPushEventChannel.setStreamHandler(OpenedPushStreamHandler.newInstance())

        let receivedPushEventChannel = FlutterEventChannel(name: receivedPushStreamName, binaryMessenger: registrar.messenger())
        receivedPushEventChannel.setStreamHandler(ReceivedPushStreamHandler.newInstance())
    }

    var exponeaInstance: ExponeaType = ExponeaSDK.Exponea.shared

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case methodConfigure:
            configure(call.arguments, with: result)
        case methodIsConfigured:
            isConfigured(with: result)
        case methodGetCustomerCookie:
            getCustomerCookie(with: result)
        case methodIdentifyCustomer:
            identifyCustomer(call.arguments, with: result)
        case methodAnonymize:
            anonymize(call.arguments, with: result)
        case methodGetDefaultProperties:
            getDefaultProperties(with: result)
        case methodSetDefaultProperties:
            setDefaultProperties(call.arguments, with: result)
        case methodFlush:
            flush(with: result)
        case methodGetFlushMode:
            getFlushMode(with: result)
        case methodSetFlushMode:
            setFlushMode(call.arguments, with: result)
        case methodGetFlushPeriod:
            getFlushPeriod(with: result)
        case methodSetFlushPeriod:
            setFlushPeriod(call.arguments, with: result)
        case methodTrackEvent:
            trackEvent(call.arguments, with: result)
        case methodTrackSessionStart:
            trackSessionStart(call.arguments, with: result)
        case methodTrackSessionEnd:
            trackSessionEnd(call.arguments, with: result)
        case methodFetchConsents:
            fetchConsents(with: result)
        case methodFetchRecommendations:
            fetchRecommendations(call.arguments, with: result)
        case methodGetLogLevel:
            getLogLevel(with: result)
        case methodSetLogLevel:
            setLogLevel(call.arguments, with: result)
        case methodCheckPushSetup:
            checkPushSetup(with: result)
        case methodRequestPushAuthorization:
            requestPushAuthorization(with: result)
        default:
            let error = FlutterError(code: errorCode, message: "\(call.method) is not supported by iOS", details: nil)
            result(error)
        }
    }

    private func configure(_ args: Any?, with result: FlutterResult) {
        guard !exponeaInstance.isConfigured else {
            result(false)
            return
        }
        do {
            let data = args as! [String:Any?]

            let parser = ConfigurationParser()
            let config = try parser.parseConfig(data)

            // exponeaInstance.checkPushSetup = true
            exponeaInstance.configure(
                config.projectSettings,
                pushNotificationTracking: config.pushNotificationTracking,
                automaticSessionTracking: config.automaticSessionTracking,
                defaultProperties: config.defaultProperties,
                flushingSetup: config.flushingSetup,
                allowDefaultCustomerProperties: config.allowDefaultCustomerProperties
            )
            exponeaInstance.pushNotificationsDelegate = self
            result(true)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func isConfigured(with result: FlutterResult) {
        result(exponeaInstance.isConfigured)
    }

    private func getCustomerCookie(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        result(exponeaInstance.customerCookie)
    }

    private func identifyCustomer(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let customer = try ExponeaCustomer(data)
            exponeaInstance.identifyCustomer(customerIds: customer.ids, properties: customer.properties, timestamp: nil)
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func anonymize(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let parser = ConfigurationParser()
            let change = try parser.parseConfigChange(data, defaultBaseUrl: exponeaInstance.configuration!.baseUrl)
            if let project = change.project {
                exponeaInstance.anonymize(exponeaProject: project, projectMapping: change.mapping)
            } else {
                exponeaInstance.anonymize()
            }
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func getDefaultProperties(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        result(exponeaInstance.defaultProperties)
    }

    private func setDefaultProperties(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let props = try JsonDataParser.parse(dictionary: data)
            exponeaInstance.defaultProperties = props
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func flush(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        exponeaInstance.flushData()
        result(nil)
    }

    private func getFlushMode(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let encoder = FlushModeEncoder()
        let mode = encoder.encode(exponeaInstance.flushingMode)
        result(mode)
    }

    private func setFlushMode(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let encoder = FlushModeEncoder()
        do {
            let data = args as! String
            let mode = try encoder.decode(data)
            exponeaInstance.flushingMode = mode
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func getFlushPeriod(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        switch exponeaInstance.flushingMode {
        case .periodic(let period):
            result(period)
        default:
            let error = FlutterError(code: errorCode, message: ExponeaError.flushModeNotPeriodic.localizedDescription, details: nil)
            result(error)
        }
    }

    private func setFlushPeriod(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let period = args as! Int
        switch exponeaInstance.flushingMode {
        case .periodic:
            exponeaInstance.flushingMode = .periodic(period)
            result(nil)
        default:
            let error = FlutterError(code: errorCode, message: ExponeaError.flushModeNotPeriodic.localizedDescription, details: nil)
            result(error)
        }
    }

    private func trackEvent(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let event = try ExponeaEvent(data)
            exponeaInstance.trackEvent(properties: event.properties, timestamp: event.timestamp, eventType: event.name)
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func trackSessionStart(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let timestamp = args as? Double
        guard timestamp == nil else {
            let error = FlutterError(code: errorCode, message: ExponeaError.notAvailableForPlatform(name: "Setting session start timestamp").localizedDescription, details: nil)
            result(error)
            return
        }
        exponeaInstance.trackSessionStart()
        result(nil)
    }

    private func trackSessionEnd(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let timestamp = args as? Double
        guard timestamp == nil else {
            let error = FlutterError(code: errorCode, message: ExponeaError.notAvailableForPlatform(name: "Setting session start timestamp").localizedDescription, details: nil)
            result(error)
            return
        }
        exponeaInstance.trackSessionEnd()
        result(nil)
    }

    private func fetchConsents(with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        exponeaInstance.fetchConsents { fetchResult in
            switch fetchResult {
            case .success(let response):
                let outData = response.consents.map { ConsentEncoder.encode($0) }
                result(outData)
            case .failure(let error):
                let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                result(error)
            }
        }
    }

    private func fetchRecommendations(_ args: Any?, with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let options = try RecommendationOptionsEncoder.decode(data)
            exponeaInstance.fetchRecommendation(
                with: options,
                completion: {(fetchResult: Result<RecommendationResponse<AllRecommendationData>>) in
                    switch fetchResult {
                    case .success(let response):
                        guard let responseValue = response.value else {
                            let error = FlutterError(code: errorCode, message: ExponeaError.fetchError(description: "Empty result.").localizedDescription, details: nil)
                            result(error)
                            return
                        }
                        let outData = responseValue.map { $0.userData.formattedData() }
                        result(outData)
                    case .failure(let error):
                        let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                        result(error)
                    }
                }
            )
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func getLogLevel(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let encoder = LogLevelEncoder()
        let logLevel = encoder.encode(ExponeaSDK.Exponea.logger.logLevel)
        result(logLevel)
    }

    private func setLogLevel(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let encoder = LogLevelEncoder()
        do {
            let data = args as! String
            let logLevel = try encoder.decode(data)
            ExponeaSDK.Exponea.logger.logLevel = logLevel
            result(nil)
        } catch {
            let error = FlutterError(code: "2", message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func checkPushSetup(with result: FlutterResult) {
        guard requireNotConfigured(with: result) else { return }
        exponeaInstance.checkPushSetup = true
        result(nil)
    }

    private func requestPushAuthorization(with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, _) in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                result(granted)
            }
        }
    }

    private func requireNotConfigured(with result: FlutterResult) -> Bool {
        guard !exponeaInstance.isConfigured else {
            let error = FlutterError(code: "2", message: ExponeaError.alreadyConfigured.localizedDescription, details: nil)
            result(error)
            return false
        }
        return true
    }

    private func requireConfigured(with result: FlutterResult) -> Bool {
        guard exponeaInstance.isConfigured else {
            let error = FlutterError(code: errorCode, message: ExponeaError.notConfigured.localizedDescription, details: nil)
            result(error)
            return false
        }
        return true
    }

}

extension SwiftExponeaPlugin: PushNotificationManagerDelegate {
    public func pushNotificationOpened(
        with action: ExponeaNotificationActionType,
        value: String?,
        extraData: [AnyHashable: Any]?
    ) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: extraData ?? [:], options: []),
              let rawData = try? JSONDecoder.snakeCase.decode(RawData.self, from: jsonData) else {
            ExponeaSDK.Exponea.logger.log(.error, message: "Unable to serialize opened push.")
            return
        }

        let openedPush = OpenedPush(
            action: PushAction.from(actionType: action),
            url: value,
            data: rawData.data
        )
        _ = OpenedPushStreamHandler.handle(push: openedPush)
    }

    public func silentPushNotificationReceived(extraData: [AnyHashable: Any]?) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: extraData ?? [:], options: []),
              let rawData = try? JSONDecoder.snakeCase.decode(RawData.self, from: jsonData) else {
            ExponeaSDK.Exponea.logger.log(.error, message: "Unable to serialize opened push.")
            return
        }

        let receivedPush = ReceivedPush(data: rawData.data)
        _ = ReceivedPushStreamHandler.handle(push: receivedPush)
    }

    @objc
    public static func handlePushNotificationToken(deviceToken: Data) {
        ExponeaSDK.Exponea.shared.handlePushNotificationToken(deviceToken: deviceToken)
    }

    @objc
    public static func handlePushNotificationOpened(userInfo: [AnyHashable: Any]) {
        ExponeaSDK.Exponea.shared.handlePushNotificationOpened(userInfo: userInfo)
    }

    @objc
    public static func handlePushNotificationOpened(response: UNNotificationResponse) {
        ExponeaSDK.Exponea.shared.handlePushNotificationOpened(response: response)
    }

    @objc
    static func continueUserActivity(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
            else { return }
        ExponeaSDK.Exponea.shared.trackCampaignClick(url: incomingURL, timestamp: nil)
    }
}

extension PushAction {
    static func from(actionType: ExponeaNotificationActionType) -> PushAction {
        switch actionType {
        case .none: return .app
        case .openApp: return .app
        case .deeplink: return .deeplink
        case .browser: return .web
        case .selfCheck: return .app
        }
    }
}
