//
//  SegmentationDataStreamHandler.swift
//  exponea
//

import Foundation
import Flutter

public class SegmentationDataStreamHandler: NSObject, FlutterStreamHandler {
    private static var currentInstance: SegmentationDataStreamHandler?

    // We have to hold SegmentationData until plugin is initialized and listener set
    private static var pendingData: SegmentationData?

    static func handle(segmentationData: SegmentationData) -> Bool {
        let handled = currentInstance?.internalHandle(segmentationData: segmentationData) ?? false
        if (!handled) {
            pendingData = segmentationData
        }
        return handled
    }

    static func newInstance() -> SegmentationDataStreamHandler {
        let handler = SegmentationDataStreamHandler()
        currentInstance = handler
        return handler
    }

    private override init() {}

    private var eventSink: FlutterEventSink?

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        if let data = SegmentationDataStreamHandler.pendingData {
            if (SegmentationDataStreamHandler.handle(segmentationData: data)) {
                SegmentationDataStreamHandler.pendingData = nil
            }
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    private func internalHandle(segmentationData: SegmentationData) -> Bool {
        guard let sink = eventSink else {
            return false
        }
        sink(segmentationData.toMap())
        return true
    }
}
