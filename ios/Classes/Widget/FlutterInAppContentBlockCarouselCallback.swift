//
//  FlutterContentBlockCarouselCallback.swift
//  exponea
//

import Foundation
import ExponeaSDK

class FlutterInAppContentBlockCarouselCallback : DefaultContentBlockCarouselCallback {
    var overrideDefaultBehavior: Bool
    var trackActions: Bool
    
    private let channel: FlutterMethodChannel
    private let methodOnInAppContentBlockCarouselEvent = "onInAppContentBlockCarouselEvent"
    
    init(overrideDefaultBehavior: Bool, trackActions: Bool, channel: FlutterMethodChannel) {
        self.overrideDefaultBehavior = overrideDefaultBehavior
        self.trackActions = trackActions
        self.channel = channel
    }
    
    func onMessageShown(placeholderId: String, contentBlock: ExponeaSDK.InAppContentBlockResponse, index: Int, count: Int) {
        let payload: [String: Any?] = [
            "eventType": "onMessageShown",
            "placeholderId": placeholderId,
            "contentBlock": try? String(data: JSONEncoder().encode(contentBlock), encoding: .utf8),
            "index": index,
            "count": count
        ]
        invokeMethod(method: methodOnInAppContentBlockCarouselEvent, arguments: payload)
    }
    
    func onMessagesChanged(count: Int, messages: [ExponeaSDK.InAppContentBlockResponse]) {
        let payload: [String: Any?] = [
            "eventType": "onMessagesChanged",
            "count": count,
            "messages": messages.map { String(data: try! JSONEncoder().encode($0), encoding: .utf8 )}
        ]
        invokeMethod(method: methodOnInAppContentBlockCarouselEvent, arguments: payload)
    }
    
    func onNoMessageFound(placeholderId: String) {
        let payload: [String: Any?] = [
            "eventType": "onNoMessageFound",
            "placeholderId": placeholderId
        ]
        invokeMethod(method: methodOnInAppContentBlockCarouselEvent, arguments: payload)
    }
    
    func onError(placeholderId: String, contentBlock: ExponeaSDK.InAppContentBlockResponse?, errorMessage: String) {
        let payload: [String: Any?] = [
            "eventType": "onError",
            "placeholderId": placeholderId,
            "contentBlock": try? String(data: JSONEncoder().encode(contentBlock), encoding: .utf8),
            "errorMessage": errorMessage
        ]
        invokeMethod(method: methodOnInAppContentBlockCarouselEvent, arguments: payload)
    }
    
    func onCloseClicked(placeholderId: String, contentBlock: ExponeaSDK.InAppContentBlockResponse) {
        let payload: [String: Any?] = [
            "eventType": "onCloseClicked",
            "placeholderId": placeholderId,
            "contentBlock": try? String(data: JSONEncoder().encode(contentBlock), encoding: .utf8),
        ]
        invokeMethod(method: methodOnInAppContentBlockCarouselEvent, arguments: payload)
    }
    
    func onActionClickedSafari(placeholderId: String, contentBlock: ExponeaSDK.InAppContentBlockResponse, action: ExponeaSDK.InAppContentBlockAction) {
        let payload: [String: Any?] = [
            "eventType": "onActionClicked",
            "placeholderId": placeholderId,
            "contentBlock": try? String(data: JSONEncoder().encode(contentBlock), encoding: .utf8),
            "action": try? InAppContentBlockActionCoder.encode(action)
        ]
        invokeMethod(method: methodOnInAppContentBlockCarouselEvent, arguments: payload)
    }
    
    func onHeightUpdate(placeholderId: String, height: CGFloat) {
        let payload: [String: Any] = [
            "eventType": "onHeightUpdate",
            "placeholderId": placeholderId,
            "height": height,
        ]
        invokeMethod(method: methodOnInAppContentBlockCarouselEvent, arguments: payload)
    }
    
    private func invokeMethod(method: String, arguments: [String: Any?]) {
        DispatchQueue.main.async {
            self.channel.invokeMethod(method, arguments: arguments)
        }
    }
}
