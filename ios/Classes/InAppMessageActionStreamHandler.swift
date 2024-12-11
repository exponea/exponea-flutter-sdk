//
//  InAppMessageActionStreamHandler.swift
//  exponea
//

import Foundation
import ExponeaSDK
import Flutter

public class InAppMessageActionStreamHandler: NSObject, FlutterStreamHandler, InAppMessageActionDelegate {
    private(set) static var currentInstance: InAppMessageActionStreamHandler = InAppMessageActionStreamHandler()

    // We have to hold inAppMessage until plugin is initialized and listener set
    private var pendingData: InAppMessageAction?
    
    public var overrideDefaultBehavior: Bool = false
    
    public var trackActions: Bool = true
    
    private override init() {}

    private var eventSink: FlutterEventSink?

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        if let data = pendingData {
            if handle(action: data) {
                pendingData = nil
            }
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        overrideDefaultBehavior = false
        trackActions = true
        return nil
    }
    
    private func handle(action: InAppMessageAction) -> Bool {
        guard let sink = eventSink else {
            pendingData = action
            return false
        }
        sink(action.toMap())
        return true
    }

    public func inAppMessageShown(message: ExponeaSDK.InAppMessage) {
        _ = handle(action: InAppMessageAction(
            type: .show,
            message: message
        ))
    }

    public func inAppMessageError(message: ExponeaSDK.InAppMessage?, errorMessage: String) {
        _ = handle(action: InAppMessageAction(
            type: .error,
            message: message,
            errorMessage: errorMessage
        ))
    }
    
    public func inAppMessageClickAction(message: ExponeaSDK.InAppMessage, button: ExponeaSDK.InAppMessageButton) {
        _ = handle(action: InAppMessageAction(
            type: .click,
            message: message,
            button: button
        ))
    }
    
    public func inAppMessageCloseAction(message: ExponeaSDK.InAppMessage, button: ExponeaSDK.InAppMessageButton?, interaction: Bool) {
        _ = handle(action: InAppMessageAction(
            type: .close,
            message: message,
            button: button,
            interaction: interaction
        ))
    }

}
