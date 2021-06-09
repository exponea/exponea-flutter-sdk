import Flutter
import UIKit
import ExponeaSDK

private let channelName = "com.exponea"
private let methodConfigure = "configure"
private let methodIsConfigured = "isConfigured"

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
            let data = call.arguments as! [String:Any?]
            configure(data, with: result)
        case methodIsConfigured:
            isConfigured(with: result)
        default:
            let error = FlutterError(code: "1", message: "\(call.method) is not supported by iOS", details: nil)
            result(error)
        }
    }
    
    private func configure(_ data: [String:Any?], with result: FlutterResult) {
        do {
            guard !exponeaInstance.isConfigured else {
                throw ExponeaError.alreadyConfigured
            }
            
            let parser = ConfigurationParser()
            let projectSettings = try parser.parseProjectSettings(data)
            let pushNotificationTracking = try parser.parsePushNotificationTracking(data)
            let automaticSessionTracking = try parser.parseSessionTracking(data)
            let defaultProperties = try parser.parseDefaultProperties(data)
            let flushingSetup = try parser.parseFlushingSetup(data)
            exponeaInstance.configure(
                projectSettings,
                pushNotificationTracking: pushNotificationTracking,
                automaticSessionTracking: automaticSessionTracking,
                defaultProperties: defaultProperties,
                flushingSetup: flushingSetup
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
}
