//
//  ReceivedPushStreamHandler.swift
//  exponea
//

import Foundation
import Flutter

public class ReceivedPushStreamHandler: NSObject, FlutterStreamHandler {
    private static var currentInstance: ReceivedPushStreamHandler?

    // We have to hold OpenedPush until plugin is initialized and listener set
    private static var pendingData: ReceivedPush?

    static func handle(push: ReceivedPush) -> Bool {
        let handled = currentInstance?.internalHandle(push: push) ?? false
        if (!handled) {
            pendingData = push
        }
        return handled
    }

    static func newInstance() -> ReceivedPushStreamHandler {
        let handler = ReceivedPushStreamHandler()
        currentInstance = handler
        return handler
    }

    private override init() {}

    private var eventSink: FlutterEventSink?

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        if let data = ReceivedPushStreamHandler.pendingData {
            if (ReceivedPushStreamHandler.handle(push: data)) {
                ReceivedPushStreamHandler.pendingData = nil
            }
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    private func internalHandle(push: ReceivedPush) -> Bool {
        guard let sink = eventSink else {
            return false
        }
        sink(push.toMap())
        return true
    }
}
