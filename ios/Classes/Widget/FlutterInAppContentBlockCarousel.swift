//
//  FlutterInAppContentBlockCarousel.swift
//  exponea
//

import ExponeaSDK
import Foundation

public class FlutterInAppContentBlockCarousel: NSObject, FlutterPlatformView {

    private let channelName = "com.exponea/InAppContentBlockCarousel"
    private let methodFIlterContentBlocksResult = "filterContentBlocksResult"
    private let methodSortContentBlocksResult = "sortContentBlocksResult"

    private var inAppContentBlockCarousel: CarouselInAppContentBlockView?
    private let placeholderId: String
    private var channel: FlutterMethodChannel
    private let selectionBridge: ContentBlockCarouselSelectionBridge

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        placeholderIdentifier placeholderId: String,
        overrideDefaultBehavior: Bool,
        trackActions: Bool,
        maxMessagesCount: Int?,
        scrollDelay: TimeInterval?,
        filtrationSet: Bool,
        sortingSet: Bool,
        responseTimeoutMillis: Double?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.placeholderId = placeholderId
        let channel = FlutterMethodChannel(name: "\(channelName)/\(viewId)", binaryMessenger: messenger)
        self.channel = channel
        let responseTimeout: TimeInterval
        if let responseTimeoutMillis, responseTimeoutMillis > 0 {
            responseTimeout = responseTimeoutMillis / 1000
        } else {
            responseTimeout = 0.25
            if responseTimeoutMillis != nil {
                ExponeaSDK.Exponea.logger.log(
                    .warning,
                    message: "InAppCbCarousel: responseTimeoutMillis must be positive; using 250 ms."
                )
            }
        }
        self.selectionBridge = ContentBlockCarouselSelectionBridge(
            filtrationSet: filtrationSet,
            sortingSet: sortingSet,
            responseTimeout: responseTimeout,
            invoke: { method, contentBlocks, onHandled in
                guard EngineDeliveryGuard.isSafeToDeliver() else {
                    return false
                }
                channel.invokeMethod(
                    method,
                    arguments: contentBlocks.compactMap { contentBlock in
                        (try? JSONEncoder().encode(contentBlock)).flatMap { String(data: $0, encoding: .utf8) }
                    },
                    result: { _ in
                        // The engine delivers this reply through its own task runner, but delivers the
                        // Dart `...Result` call through the main dispatch queue, so the two can run in
                        // either order. The Dart handler sends its answer before it returns, so the answer
                        // is already queued on the main dispatch queue by now; queueing `onHandled` behind
                        // it makes it run after the answer.
                        DispatchQueue.main.async { onHandled() }
                    }
                )
                return true
            }
        )

        let callback = FlutterInAppContentBlockCarouselCallback(overrideDefaultBehavior: overrideDefaultBehavior, trackActions: trackActions, channel: channel)
        super.init()
        self.channel.setMethodCallHandler(onMethodCall)
        self.inAppContentBlockCarousel = FlutterCarouselInAppContentBlockView(
            placeholder: placeholderId,
            maxMessagesCount: maxMessagesCount,
            scrollDelay: scrollDelay,
            behaviourCallback: callback,
            widget: self
        )
        self.inAppContentBlockCarousel?.reload()
    }

    func onMethodCall(call : FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case methodFIlterContentBlocksResult:
            if !selectionBridge.filtrationSet {
                result(FlutterError(
                    code: "InAppCB",
                    message: "Handling of filtration was invoked even when filtration is not initialized", details: nil
                ))
                return
            }
            guard let ids = ContentBlockCarouselSelectionBridge.parseAnswerIds(call.arguments) else {
                result(FlutterError(
                    code: "InAppCB",
                    message: "unable to parse messages", details: nil
                ))
                return
            }
            if !selectionBridge.handleFilterResult(ids) {
                ExponeaSDK.Exponea.logger.log(.verbose, message: "InAppCbCarousel: ignoring a filter result that arrived after its timeout.")
            }
            result(nil)
        case methodSortContentBlocksResult:
            if !selectionBridge.sortingSet {
                result(FlutterError(
                    code: "InAppCB",
                    message: "Handling of sorting was invoked even when sorting is not initialized", details: nil
                ))
                return
            }
            guard let ids = ContentBlockCarouselSelectionBridge.parseAnswerIds(call.arguments) else {
                result(FlutterError(
                    code: "InAppCB",
                    message: "unable to parse messages", details: nil
                ))
                return
            }
            if !selectionBridge.handleSortResult(ids) {
                ExponeaSDK.Exponea.logger.log(.verbose, message: "InAppCbCarousel: ignoring a sort result that arrived after its timeout.")
            }
            result(nil)
        default:
            let error = FlutterError(code: "", message: "\(call.method) is not supported by iOS", details: nil)
            result(error)
            return
        }
    }

    /// Applies the Dart filter and sort without blocking the main thread; see `ContentBlockCarouselSelectionBridge`.
    func selectContentBlocks(
        _ input: [InAppContentBlockResponse],
        completion: @escaping ([InAppContentBlockResponse]) -> Void
    ) {
        selectionBridge.select(input, completion: completion)
    }

    /// Returns `data` in the order of the Dart sort, or nil when the native sort applies.
    func sortContentBlocks(_ data: [StaticReturnData]) -> [StaticReturnData]? {
        return selectionBridge.applyDartSortOrder(to: data)
    }

    public func view() -> UIView {
        return inAppContentBlockCarousel ?? UIView()
    }
}
