//
//  FlutterAppInboxDetailView.swift
//  exponea
//

import Foundation
import ExponeaSDK

public class FlutterAppInboxDetailViewFactory: NSObject, FlutterPlatformViewFactory {
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        guard let data = args as? NSDictionary,
              let messageId: String = try? data.getRequiredSafely(property: "messageId") else {
            ExponeaSDK.Exponea.logger.log(.error, message: "Unable to parse message identifier.")
            return FlutterAppInboxDetailView(frame: frame, viewId: viewId, messageId: "")
        }
        return FlutterAppInboxDetailView(frame: frame, viewId: viewId, messageId: messageId)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

public class FlutterAppInboxDetailView: NSObject, FlutterPlatformView {
    private var _viewController: UIViewController
    
    public func view() -> UIView {
        return _viewController.view
    }
    
    private let frame: CGRect
    private let viewId: Int64
    private let messageId: String
    
    init(frame: CGRect, viewId: Int64, messageId: String) {
        self.frame = frame
        self.viewId = viewId
        self.messageId = messageId
        _viewController = ExponeaSDK.Exponea.shared.getAppInboxDetailViewController(messageId)
        super.init()
    }
}
