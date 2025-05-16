//
//  FlutterInAppContentBlockCarousel.swift
//  exponea
//

import ExponeaSDK
import Foundation
import Combine

public class FlutterInAppContentBlockCarousel: NSObject, FlutterPlatformView {
    
    private let channelName = "com.exponea/InAppContentBlockCarousel"
    private let methodFilterContentBlocks = "filterContentBlocks"
    private let methodSortContentBlocks = "sortContentBlocks"
    private let methodFIlterContentBlocksResult = "filterContentBlocksResult"
    private let methodSortContentBlocksResult = "sortContentBlocksResult"
    
    private var inAppContentBlockCarousel: CarouselInAppContentBlockView?
    private let placeholderId: String
    private let filtrationSet: Bool
    private let sortingSet: Bool
    private var channel: FlutterMethodChannel
    private let responseTimeout: TimeInterval = 2
    private var filterResponse: PassthroughSubject<[InAppContentBlockResponse], Never>?
    private var sortResponse: PassthroughSubject<[InAppContentBlockResponse], Never>?
    
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
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.placeholderId = placeholderId
        self.channel = FlutterMethodChannel(name: "\(channelName)/\(viewId)", binaryMessenger: messenger)
        
        let callback = FlutterInAppContentBlockCarouselCallback(overrideDefaultBehavior: overrideDefaultBehavior, trackActions: trackActions, channel: channel)
        self.filtrationSet = filtrationSet
        self.sortingSet = sortingSet
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
            if filterResponse == nil {
                result(FlutterError(
                    code: "InAppCB",
                    message: "Handling of filtration was invoked even when filtration is not initialized", details: nil
                ))
                return
            }
            let data = call.arguments as? NSArray
            let messages = data?
                .compactMap { $0 as? String }
                .compactMap { $0.data(using: .utf8) }
                .compactMap { try? JSONDecoder().decode(InAppContentBlockResponse.self, from: $0) }
            guard let messages else {
                result(FlutterError(
                    code: "InAppCB",
                    message: "unable to parse messages", details: nil
                ))
                return
            }
            filterResponse?.send(messages)
        case methodSortContentBlocksResult:
            if sortResponse == nil {
                result(FlutterError(
                    code: "InAppCB",
                    message: "Handling of sorting was invoked even when sorting is not initialized", details: nil
                ))
                return
            }
            let data = call.arguments as? NSArray
            let messages = data?
                .compactMap { $0 as? String }
                .compactMap { $0.data(using: .utf8) }
                .compactMap { try? JSONDecoder().decode(InAppContentBlockResponse.self, from: $0) }
            guard let messages else {
                result(FlutterError(
                    code: "InAppCB",
                    message: "unable to parse messages", details: nil
                ))
                return
            }
            sortResponse?.send(messages)
        default:
            let error = FlutterError(code: "", message: "\(call.method) is not supported by iOS", details: nil)
            result(error)
            return
        }
    }
    
    func filterContentBlocks(_ input: [InAppContentBlockResponse]) -> [InAppContentBlockResponse] {
        if !filtrationSet {
            return input
        }
        filterResponse = PassthroughSubject<[InAppContentBlockResponse], Never>()
        channel.invokeMethod(methodFilterContentBlocks, arguments: input.map { String(data: try! JSONEncoder().encode($0), encoding: .utf8 )})
        let responseData = filterResponse?.retrieveFirstOrNull(timeout: responseTimeout) ?? input
        filterResponse = nil
        let filteredResponseData = retrieveMatchingById(input, responseData)
        return filteredResponseData
    }

    func sortContentBlocks(_ input: [InAppContentBlockResponse]) -> [InAppContentBlockResponse] {
        if !sortingSet {
            return input
        }
        sortResponse = PassthroughSubject<[InAppContentBlockResponse], Never>()
        channel.invokeMethod(methodSortContentBlocks, arguments: input.map { String(data: try! JSONEncoder().encode($0), encoding: .utf8 )})
        let responseData = sortResponse?.retrieveFirstOrNull(timeout: responseTimeout) ?? input
        sortResponse = nil
        let sortedResponseData = retrieveMatchingById(input, responseData)
        return sortedResponseData
    }
    
    private func retrieveMatchingById(
        _ source: [InAppContentBlockResponse],
        _ truth: [InAppContentBlockResponse]
    ) -> [InAppContentBlockResponse] {
        let idsToMatch = truth.map { $0.id }
        return source
            .filter { eachInSource in
                return idsToMatch.contains(eachInSource.id)
            }
            .sorted {
                idsToMatch.firstIndex(of: $0.id) ?? -1 < idsToMatch.firstIndex(of: $1.id) ?? -1
            }
    }
    
    public func view() -> UIView {
        return inAppContentBlockCarousel ?? UIView()
    }
}
