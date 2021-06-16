import Flutter
import UIKit
import ExponeaSDK

private let channelName = "com.exponea"
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

private let defaultFlushPeriod = 5 * 60 // 5 minutes

public class SwiftExponeaPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftExponeaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // to be changed in unit tests
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
        default:
            let error = FlutterError(code: "1", message: "\(call.method) is not supported by iOS", details: nil)
            result(error)
        }
    }
    
    private func configure(_ args: Any?, with result: FlutterResult) {
        do {
            let data = args as! [String:Any?]
            
            guard !exponeaInstance.isConfigured else {
                throw ExponeaError.alreadyConfigured
            }
            
            let parser = ConfigurationParser()
            let config = try parser.parseConfig(data)
            exponeaInstance.configure(
                config.projectSettings,
                pushNotificationTracking: config.pushNotificationTracking,
                automaticSessionTracking: config.automaticSessionTracking,
                defaultProperties: config.defaultProperties,
                flushingSetup: config.flushingSetup
            )
            
            // FIXME : Exponea.shared.pushNotificationsDelegate = self
            result(nil)
        } catch {
            let error = FlutterError(code: "2", message: error.localizedDescription, details: nil)
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
            let error = FlutterError(code: "2", message: error.localizedDescription, details: nil)
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
            let error = FlutterError(code: "2", message: error.localizedDescription, details: nil)
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
            let error = FlutterError(code: "2", message: error.localizedDescription, details: nil)
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
        switch exponeaInstance.flushingMode {
        case .automatic: result("APP_CLOSE")
        case .immediate: result("IMMEDIATE")
        case .periodic: result("PERIOD")
        case .manual: result("MANUAL")
        }
    }
    
    private func setFlushMode(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let mode = args as! String
        switch mode {
        case "APP_CLOSE":
            exponeaInstance.flushingMode = .automatic
            result(nil)
        case "IMMEDIATE":
            exponeaInstance.flushingMode = .immediate
            result(nil)
        case "PERIOD":
            exponeaInstance.flushingMode = .periodic(defaultFlushPeriod)
            result(nil)
        case "MANUAL":
            exponeaInstance.flushingMode = .manual
            result(nil)
        default:
            let error = FlutterError(code: "2", message: ExponeaDataError.invalidValue(for: "flush mode").localizedDescription, details: nil)
            result(error)
        }
    }
    
    private func getFlushPeriod(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        switch exponeaInstance.flushingMode {
        case .periodic(let period):
            result(period)
        default:
            let error = FlutterError(code: "2", message: ExponeaError.flushModeNotPeriodic.localizedDescription, details: nil)
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
            let error = FlutterError(code: "2", message: ExponeaError.flushModeNotPeriodic.localizedDescription, details: nil)
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
            let error = FlutterError(code: "2", message: error.localizedDescription, details: nil)
            result(error)
        }
    }
    
    private func trackSessionStart(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let timestamp = args as? Double
        guard timestamp == nil else {
            let error = FlutterError(code: "2", message: ExponeaError.notAvailableForPlatform(name: "Setting session start timestamp").localizedDescription, details: nil)
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
            let error = FlutterError(code: "2", message: ExponeaError.notAvailableForPlatform(name: "Setting session start timestamp").localizedDescription, details: nil)
            result(error)
            return
        }
        exponeaInstance.trackSessionEnd()
        result(nil)
    }
    
    private func requireConfigured(with result: FlutterResult) -> Bool {
        guard exponeaInstance.isConfigured else {
            let error = FlutterError(code: "2", message: ExponeaError.notConfigured.localizedDescription, details: nil)
            result(error)
            return false
        }
        return true
    }
}
