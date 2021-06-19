//
//  OpenedPushStreamHandler.swift
//  exponea
//

import Foundation
import Flutter

public class OpenedPushStreamHandler: NSObject, FlutterStreamHandler {
    private static var currentInstance: OpenedPushStreamHandler?

    // We have to hold OpenedPush until plugin is initialized and listener set
    private static var pendingData: OpenedPush?

    static func handle(push: OpenedPush) -> Bool {
        let handled = currentInstance?.internalHandle(push: push) ?? false
        if (!handled) {
            pendingData = push
        }
        return handled
    }

    static func newInstance() -> OpenedPushStreamHandler {
        let handler = OpenedPushStreamHandler()
        currentInstance = handler
        return handler
    }

    private override init() {}

    private var eventSink: FlutterEventSink?

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        if let data = OpenedPushStreamHandler.pendingData {
            if (OpenedPushStreamHandler.handle(push: data)) {
                OpenedPushStreamHandler.pendingData = nil
            }
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    private func internalHandle(push: OpenedPush) -> Bool {
        guard let sink = eventSink else {
            return false
        }
        sink(push.toMap())
        return true
    }
}
