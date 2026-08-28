//
//  SdkAuthStreamHandler.swift
//  exponea
//

import Foundation
import Flutter

public class SdkAuthStreamHandler: NSObject, FlutterStreamHandler {
    private static var currentInstance: SdkAuthStreamHandler?

    private static var pendingData: SdkAuthError?

    static func handle(error: SdkAuthError) -> Bool {
        let handled = currentInstance?.internalHandle(error: error) ?? false
        if !handled {
            pendingData = error
        }
        return handled
    }

    static func newInstance() -> SdkAuthStreamHandler {
        let handler = SdkAuthStreamHandler()
        currentInstance = handler
        return handler
    }

    private override init() {}

    private var eventSink: FlutterEventSink?

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        if let data = SdkAuthStreamHandler.pendingData {
            if SdkAuthStreamHandler.handle(error: data) {
                SdkAuthStreamHandler.pendingData = nil
            }
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    private func internalHandle(error: SdkAuthError) -> Bool {
        guard let sink = eventSink else {
            return false
        }
        sink(error.toMap())
        return true
    }
}
