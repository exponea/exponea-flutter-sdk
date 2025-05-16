//
//  FlutterInAppContentBlockCarouselFactory.swift
//  exponea
//

import ExponeaSDK
import Foundation

public class FlutterInAppContentBlockCarouselFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    private let channelName = "com.exponea/InAppContentBlockCarousel"
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        guard let data = args as? NSDictionary,
              let placeholderId: String = try? data.getRequiredSafely(property: "placeholderId"),
              let overrideDefaultBehavior: Bool = try? data.getRequiredSafely(property: "overrideDefaultBehavior"),
              let trackActions: Bool = try? data.getRequiredSafely(property: "trackActions"),
              let filtrationSet: Bool = try? data.getRequiredSafely(property: "filtrationSet"),
              let sortingSet: Bool = try? data.getRequiredSafely(property: "sortingSet") else {
          ExponeaSDK.Exponea.logger.log(.error, message: "Unable to parse placeholder identifier.")
          return FlutterInAppContentBlockCarousel(
              frame: frame,
              viewIdentifier: viewId,
              placeholderIdentifier: "",
              overrideDefaultBehavior: false,
              trackActions: false,
              maxMessagesCount: nil,
              scrollDelay: nil,
              filtrationSet: false,
              sortingSet: false,
              binaryMessenger: messenger)
      }
        let maxMessagesCount: Int? = try? data.getOptionalSafely(property: "maxMessagesCount")
        let scrollDelay: TimeInterval? = try? data.getOptionalSafely(property: "scrollDelay")
        return FlutterInAppContentBlockCarousel(
            frame: frame,
            viewIdentifier: viewId,
            placeholderIdentifier: placeholderId,
            overrideDefaultBehavior: overrideDefaultBehavior,
            trackActions: trackActions,
            maxMessagesCount: maxMessagesCount,
            scrollDelay: scrollDelay,
            filtrationSet: filtrationSet,
            sortingSet: sortingSet,
            binaryMessenger: messenger)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
