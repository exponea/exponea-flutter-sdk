//
//  FlutterAppInboxListView.swift
//  exponea
//

import Foundation
import ExponeaSDK

public class FlutterAppInboxListViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return FlutterAppInboxListView(frame: frame, viewId: viewId, messenger: messenger)
    }
}

public class FlutterAppInboxListView: NSObject, FlutterPlatformView {
    private let channelName = "com.exponea/AppInboxListView"
    private let methodOnAppInboxItemClicked = "onAppInboxItemClicked"
    
    private let _viewController : UIViewController
    private var channel: FlutterMethodChannel

    public func view() -> UIView {
        return _viewController.view
    }
    
    private let frame: CGRect
    private let viewId: Int64
    private let messenger: FlutterBinaryMessenger
    
    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger) {
        self.frame = frame
        self.viewId = viewId
        self.messenger = messenger
        channel = FlutterMethodChannel(name: "\(channelName)/\(viewId)", binaryMessenger: messenger)
        _viewController = ExponeaSDK.Exponea.shared.getAppInboxListViewController()
        let viewController = _viewController as? AppInboxListViewController
        super.init()
        viewController?.onItemClickedOverride = { (messageItem: MessageItem, _: Int) in
            self.onItemClicked(item: messageItem)
        }
    }
    
    private func onItemClicked(item: MessageItem) {
        DispatchQueue.main.async {
            self.channel.invokeMethod(self.methodOnAppInboxItemClicked, arguments: try? AppInboxCoder.encode(item))
        }
    }
}
