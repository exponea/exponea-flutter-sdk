import Flutter
import UIKit
import ExponeaSDK
import UserNotifications
import Foundation
import WebKit

private let channelName = "com.exponea"
private let openedPushStreamName = "\(channelName)/opened_push"
private let receivedPushStreamName = "\(channelName)/received_push"
private let inAppMessagesStreamName = "\(channelName)/in_app_messages"

enum METHOD_NAME: String {
    case methodConfigure = "configure"
    case methodIsConfigured = "isConfigured"
    case methodGetCustomerCookie = "getCustomerCookie"
    case methodIdentifyCustomer = "identifyCustomer"
    case methodAnonymize = "anonymize"
    case methodGetDefaultProperties = "getDefaultProperties"
    case methodSetDefaultProperties = "setDefaultProperties"
    case methodFlush = "flush"
    case methodGetFlushMode = "getFlushMode"
    case methodSetFlushMode = "setFlushMode"
    case methodGetFlushPeriod = "getFlushPeriod"
    case methodSetFlushPeriod = "setFlushPeriod"
    case methodTrackEvent = "trackEvent"
    case methodTrackSessionStart = "trackSessionStart"
    case methodTrackSessionEnd = "trackSessionEnd"
    case methodFetchConsents = "fetchConsents"
    case methodFetchRecommendations = "fetchRecommendations"
    case methodGetLogLevel = "getLogLevel"
    case methodSetLogLevel = "setLogLevel"
    case methodCheckPushSetup = "checkPushSetup"
    case methodRequestPushAuthorization = "requestPushAuthorization"
    case setAppInboxProvider = "setAppInboxProvider"
    case trackAppInboxOpened = "trackAppInboxOpened"
    case trackAppInboxOpenedWithoutTrackingConsent = "trackAppInboxOpenedWithoutTrackingConsent"
    case trackAppInboxClick = "trackAppInboxClick"
    case trackAppInboxClickWithoutTrackingConsent = "trackAppInboxClickWithoutTrackingConsent"
    case markAppInboxAsRead = "markAppInboxAsRead"
    case fetchAppInbox = "fetchAppInbox"
    case fetchAppInboxItem = "fetchAppInboxItem"
    case setInAppMessageActionHandler = "setInAppMessageActionHandler"
}


private let defaultFlushPeriod = 5 * 60 // 5 minutes

private let errorCode = "ExponeaPlugin"

// This protocol is queried using reflection by native iOS SDK to see if it's run by Flutter SDK
@objc(IsExponeaFlutterSDK)
protocol IsExponeaFlutterSDK {
}

@objc(ExponeaFlutterVersion)
public class ExponeaFlutterVersion: NSObject, ExponeaVersionProvider {
    required public override init() { }
    public func getVersion() -> String {
        "1.6.0"
    }
}

public class FluffViewFactory: NSObject, FlutterPlatformViewFactory {
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        FluffView(frame: frame, viewId: viewId)
    }
}

public class FluffView: NSObject, FlutterPlatformView {
    public func view() -> UIView {ExponeaSDK.Exponea.shared.getAppInboxButton()
    }
    
    let frame: CGRect
    let viewId: Int64
    
    init(frame: CGRect, viewId: Int64) {
        self.frame = frame
        self.viewId = viewId
    }
}

public class FlutterInAppContentBlockPlaceholderFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        guard let data = args as? NSDictionary,
              let placeholderId: String = try? data.getRequiredSafely(property: "placeholderId") else {
            ExponeaSDK.Exponea.logger.log(.error, message: "Unable to parse placeholder identifier.")
            return FlutterInAppContentBlockPlaceholder(
                frame: frame,
                viewIdentifier: viewId,
                placeholderIdentifier: "",
                inAppContentBlockPlaceholderView: nil,
                binaryMessenger: messenger)
        }
        let inAppContentBlockPlaceholder = StaticInAppContentBlockView(placeholder: placeholderId, deferredLoad: true)
        return FlutterInAppContentBlockPlaceholder(
            frame: frame,
            viewIdentifier: viewId,
            placeholderIdentifier: placeholderId,
            inAppContentBlockPlaceholderView: inAppContentBlockPlaceholder,
            binaryMessenger: messenger)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

public class FlutterInAppContentBlockPlaceholder: NSObject, FlutterPlatformView {
    
    private let channelName = "com.exponea/InAppContentBlockPlaceholder"
    private let methodHandleInAppContentBlockClick = "handleInAppContentBlockClick"
    
    private let inAppContentBlockPlaceholder: StaticInAppContentBlockView?
    private let placeholderId: String
    private var channel: FlutterMethodChannel?
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        placeholderIdentifier placeholderId: String,
        inAppContentBlockPlaceholderView inAppContentBlockPlaceholder: StaticInAppContentBlockView?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        self.inAppContentBlockPlaceholder = inAppContentBlockPlaceholder
        self.placeholderId = placeholderId
        super.init()
        
        if let inAppContentBlockPlaceholder,
            let messenger {
            channel = FlutterMethodChannel(name: "\(channelName)/\(viewId)", binaryMessenger: messenger)
            guard let channel else { return }
            channel.setMethodCallHandler(onMethodCall)
            
            let origBehaviour = inAppContentBlockPlaceholder.behaviourCallback
            inAppContentBlockPlaceholder.behaviourCallback = CustomInAppContentBlockCallback(originalBehaviour: origBehaviour, channel: channel)
            inAppContentBlockPlaceholder.reload()
        }
    }
    
    func onMethodCall(call : FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case methodHandleInAppContentBlockClick:
            if inAppContentBlockPlaceholder == nil {
                result(FlutterError(
                    code: "InAppCB",
                    message: "Handling of url was invoked even when InAppCB is not initialized", details: nil
                ))
                return
            }
            guard let data = call.arguments as? NSDictionary,
                  let actionUrl: String = try? data.getRequiredSafely(property: "actionUrl") else {
                result(FlutterError(
                    code: "InAppCB",
                    message: "unable to parse action URL ", details: nil
                ))
                return
            }
            inAppContentBlockPlaceholder?.invokeActionClick(actionUrl:actionUrl)
        default:
            let error = FlutterError(code: errorCode, message: "\(call.method) is not supported by iOS", details: nil)
            result(error)
            return
        }
    }
    
    public func view() -> UIView {
        return inAppContentBlockPlaceholder ?? UIView()
    }
}

public class CustomInAppContentBlockCallback: InAppContentBlockCallbackType {
    
    private let originalBehaviour: InAppContentBlockCallbackType
    
    private let channel: FlutterMethodChannel
    private let methodOnInAppContentBlockHtmlChanged = "onInAppContentBlockHtmlChanged"
    
    init(originalBehaviour: InAppContentBlockCallbackType, channel: FlutterMethodChannel) {
        self.originalBehaviour = originalBehaviour
        self.channel = channel
    }
    
    public func onMessageShown(placeholderId: String, contentBlock: ExponeaSDK.InAppContentBlockResponse) {
        originalBehaviour.onMessageShown(placeholderId: placeholderId, contentBlock: contentBlock)
        let htmlContent = contentBlock.content?.html ?? contentBlock.personalizedMessage?.content?.html
        let normalizerConf = HtmlNormalizerConfig(makeResourcesOffline: true, ensureCloseButton: false)
        if let htmlContent,
            var normalizedHtml = HtmlNormalizer(htmlContent).normalize(normalizerConf).html {
            let arguments: [String: Any?] = ["htmlContent": normalizedHtml]
            DispatchQueue.main.async {
                self.channel.invokeMethod(self.methodOnInAppContentBlockHtmlChanged, arguments: arguments)
            }
        }
    }
    
    public func onNoMessageFound(placeholderId: String) {
        originalBehaviour.onNoMessageFound(placeholderId: placeholderId)
        let arguments: [String: Any?] = ["htmlContent": nil]
        DispatchQueue.main.async {
            self.channel.invokeMethod(self.methodOnInAppContentBlockHtmlChanged, arguments: arguments)
        }
    }
    
    public func onError(placeholderId: String, contentBlock: ExponeaSDK.InAppContentBlockResponse?, errorMessage: String) {
        originalBehaviour.onError(placeholderId: placeholderId, contentBlock: contentBlock, errorMessage: errorMessage)
    }
    
    public func onCloseClicked(placeholderId: String, contentBlock: ExponeaSDK.InAppContentBlockResponse) {
        originalBehaviour.onCloseClicked(placeholderId: placeholderId, contentBlock: contentBlock)
    }
    
    public func onActionClicked(placeholderId: String, contentBlock: ExponeaSDK.InAppContentBlockResponse, action: ExponeaSDK.InAppContentBlockAction) {
        originalBehaviour.onActionClicked(placeholderId: placeholderId, contentBlock: contentBlock, action: action)
    }
}

public class SwiftExponeaPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftExponeaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let openedPushEventChannel = FlutterEventChannel(name: openedPushStreamName, binaryMessenger: registrar.messenger())
        openedPushEventChannel.setStreamHandler(OpenedPushStreamHandler.newInstance())

        let receivedPushEventChannel = FlutterEventChannel(name: receivedPushStreamName, binaryMessenger: registrar.messenger())
        receivedPushEventChannel.setStreamHandler(ReceivedPushStreamHandler.newInstance())
        
        let inAppMessagesChannel = FlutterEventChannel(name: inAppMessagesStreamName, binaryMessenger: registrar.messenger())
        inAppMessagesChannel.setStreamHandler(InAppMessageActionStreamHandler.currentInstance)

        registrar.register(FluffViewFactory(), withId: "FluffView")
        registrar.register(FlutterInAppContentBlockPlaceholderFactory(messenger: registrar.messenger()), withId: "InAppContentBlockPlaceholder")
    }

    var exponeaInstance: ExponeaType = ExponeaSDK.Exponea.shared

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = METHOD_NAME(rawValue: call.method) else {
            let error = FlutterError(code: errorCode, message: "\(call.method) is not supported by iOS", details: nil)
            result(error)
            return
        }
        switch method {
        case .methodConfigure:
            configure(call.arguments, with: result)
        case .methodIsConfigured:
            isConfigured(with: result)
        case .methodGetCustomerCookie:
            getCustomerCookie(with: result)
        case .methodIdentifyCustomer:
            identifyCustomer(call.arguments, with: result)
        case .methodAnonymize:
            anonymize(call.arguments, with: result)
        case .methodGetDefaultProperties:
            getDefaultProperties(with: result)
        case .methodSetDefaultProperties:
            setDefaultProperties(call.arguments, with: result)
        case .methodFlush:
            flush(with: result)
        case .methodGetFlushMode:
            getFlushMode(with: result)
        case .methodSetFlushMode:
            setFlushMode(call.arguments, with: result)
        case .methodGetFlushPeriod:
            getFlushPeriod(with: result)
        case .methodSetFlushPeriod:
            setFlushPeriod(call.arguments, with: result)
        case .methodTrackEvent:
            trackEvent(call.arguments, with: result)
        case .methodTrackSessionStart:
            trackSessionStart(call.arguments, with: result)
        case .methodTrackSessionEnd:
            trackSessionEnd(call.arguments, with: result)
        case .methodFetchConsents:
            fetchConsents(with: result)
        case .methodFetchRecommendations:
            fetchRecommendations(call.arguments, with: result)
        case .methodGetLogLevel:
            getLogLevel(with: result)
        case .methodSetLogLevel:
            setLogLevel(call.arguments, with: result)
        case .methodCheckPushSetup:
            checkPushSetup(with: result)
        case .methodRequestPushAuthorization:
            requestPushAuthorization(with: result)
        case .setAppInboxProvider:
            setupAppInbox(call.arguments, with: result)
        case .trackAppInboxOpened:
            trackAppInboxOpened(call.arguments, with: result)
        case .trackAppInboxOpenedWithoutTrackingConsent:
            trackAppInboxOpenedWithoutTrackingConsent(call.arguments, with: result)
        case .trackAppInboxClick:
            trackAppInboxClick(call.arguments, with: result)
        case .trackAppInboxClickWithoutTrackingConsent:
            trackAppInboxClickWithoutTrackingConsent(call.arguments, with: result)
        case .markAppInboxAsRead:
            markAppInboxAsRead(call.arguments, with: result)
        case .fetchAppInbox:
            fetchAppInbox(with: result)
        case .fetchAppInboxItem:
            fetchAppInboxItem(call.arguments, with: result)
        case .setInAppMessageActionHandler:
            setInAppMessageActionHandler(call.arguments, with: result)
        }
    }
    
    private func trackAppInboxOpened(_ args: Any?, with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            guard let data = args as? NSDictionary,
                  let messageId: String = try data.getRequiredSafely(property: "id") else {
                result(FlutterError(
                    code: errorCode,
                    message: "AppInbox message data are invalid. See logs", details: "no ID"
                ))
                return
            }
            // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
            exponeaInstance.fetchAppInboxItem(messageId) { nativeMessageResult in
                switch nativeMessageResult {
                case .success(let nativeMessage):
                    self.exponeaInstance.trackAppInboxOpened(message: nativeMessage)
                    result(nil)
                case .failure(let error):
                    let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                    result(error)
                }
            }
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }
    
    private func trackAppInboxOpenedWithoutTrackingConsent(_ args: Any?, with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            guard let data = args as? NSDictionary,
                  let messageId: String = try data.getRequiredSafely(property: "id") else {
                result(FlutterError(
                    code: errorCode,
                    message: "AppInbox message data are invalid. See logs", details: "no ID"
                ))
                return
            }
            // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
            exponeaInstance.fetchAppInboxItem(messageId) { nativeMessageResult in
                switch nativeMessageResult {
                case .success(let nativeMessage):
                    self.exponeaInstance.trackAppInboxOpenedWithoutTrackingConsent(message: nativeMessage)
                    result(nil)
                case .failure(let error):
                    let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                    result(error)
                }
            }
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }
    
    private func trackAppInboxClick(_ args: Any?, with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            guard let data = args as? NSDictionary,
                  let messageData: NSDictionary = try? data.getRequiredSafely(property: "message"),
                  let messageId: String = try messageData.getRequiredSafely(property: "id"),
                  let actionData: NSDictionary = try? data.getRequiredSafely(property: "action") else {
                result(FlutterError(
                    code: errorCode,
                    message: "AppInbox message data are invalid. See logs", details: "no message or action"
                ))
                return
            }
            // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
            exponeaInstance.fetchAppInboxItem(messageId) { nativeMessageResult in
                switch nativeMessageResult {
                case .success(let nativeMessage):
                    do {
                        let action = MessageItemAction(
                            action: try actionData.getOptionalSafely(property: "action"),
                            title: try actionData.getOptionalSafely(property: "title"),
                            url: try actionData.getOptionalSafely(property: "url")
                        )
                        self.exponeaInstance.trackAppInboxClick(action: action, message: nativeMessage)
                        result(nil)
                    } catch {
                        let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                        result(error)
                    }
                case .failure(let error):
                    let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                    result(error)
                }
            }
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }
    
    private func trackAppInboxClickWithoutTrackingConsent(_ args: Any?, with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            guard let data = args as? NSDictionary,
                  let messageData: NSDictionary = try? data.getRequiredSafely(property: "message"),
                  let messageId: String = try messageData.getRequiredSafely(property: "id"),
                  let actionData: NSDictionary = try? data.getRequiredSafely(property: "action") else {
                result(FlutterError(
                    code: errorCode,
                    message: "AppInbox message data are invalid. See logs", details: "no message or action"
                ))
                return
            }
            // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
            exponeaInstance.fetchAppInboxItem(messageId) { nativeMessageResult in
                switch nativeMessageResult {
                case .success(let nativeMessage):
                    do {
                        let action = MessageItemAction(
                            action: try actionData.getOptionalSafely(property: "action"),
                            title: try actionData.getOptionalSafely(property: "title"),
                            url: try actionData.getOptionalSafely(property: "url")
                        )
                        self.exponeaInstance.trackAppInboxClickWithoutTrackingConsent(action: action, message: nativeMessage)
                        result(nil)
                    } catch {
                        let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                        result(error)
                    }
                case .failure(let error):
                    let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                    result(error)
                }
            }
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }
    
    private func markAppInboxAsRead(_ args: Any?, with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            guard let data = args as? NSDictionary,
                  let messageId: String = try data.getRequiredSafely(property: "id") else {
                result(FlutterError(
                    code: errorCode,
                    message: "AppInbox message data are invalid. See logs", details: "no ID"
                ))
                return
            }
            exponeaInstance.fetchAppInboxItem(messageId) { nativeMessageResult in
                switch nativeMessageResult {
                case .success(let nativeMessage):
                    // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
                    self.exponeaInstance.markAppInboxAsRead(nativeMessage) { marked in
                        result(marked)
                    }
                case .failure(let error):
                    let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                    result(error)
                }
            }
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }
    
    private func fetchAppInbox(with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        exponeaInstance.fetchAppInbox { fetchResult in
            switch fetchResult {
            case .success(let response):
                do {
                    let outData: [[String: Any?]] = try response.map({ item in
                        try AppInboxCoder.encode(item)
                    })
                    result(outData)
                } catch {
                    let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                    result(error)
                }
            case .failure(let error):
                let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                result(error)
            }
        }
    }
    
    private func fetchAppInboxItem(_ args: Any?, with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        guard let messageId = args as? String else {
            result(FlutterError(
                code: errorCode,
                message: "AppInbox message ID is invalid. See logs", details: "no ID"
            ))
            return
        }
        exponeaInstance.fetchAppInboxItem(messageId) { fetchResult in
            switch fetchResult {
            case .success(let message):
                do {
                    result(try AppInboxCoder.encode(message))
                } catch {
                    let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                    result(error)
                }
            case .failure(let error):
                let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                result(error)
            }
        }
    }
    
    private func setInAppMessageActionHandler(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            guard let params = args as? NSDictionary,
                  let overrideDefaultBehavior: Bool = try params.getRequiredSafely(property: "overrideDefaultBehavior"),
                  let trackActions: Bool = try params.getRequiredSafely(property: "trackActions") else {
                result(FlutterError(
                    code: errorCode,
                    message: "Requiered function params missing", details: "no overrideDefaultBehavior or trackActions"
                ))
                return
            }
            InAppMessageActionStreamHandler.currentInstance.overrideDefaultBehavior = overrideDefaultBehavior
            InAppMessageActionStreamHandler.currentInstance.trackActions = trackActions
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }
    
    private func setupAppInbox(_ args: Any?, with result: FlutterResult) {
        guard let configMap = args as? NSDictionary,
              let appInboxStyle = try? AppInboxStyleParser(configMap).parse() else {
            result(FlutterError(code: errorCode, message: "Unable to parse AppInboxStyle data", details: nil))
            return
        }
        exponeaInstance.appInboxProvider = StyledAppInboxProvider(appInboxStyle)
        result(nil)
    }

    private func configure(_ args: Any?, with result: FlutterResult) {
        guard !exponeaInstance.isConfigured else {
            result(false)
            return
        }
        do {
            let data = args as! [String:Any?]
            let parser = ConfigurationParser()
            let config = try parser.parseConfig(data)

            // exponeaInstance.checkPushSetup = true
            exponeaInstance.configure(
                config.projectSettings,
                pushNotificationTracking: config.pushNotificationTracking,
                automaticSessionTracking: config.automaticSessionTracking,
                defaultProperties: config.defaultProperties,
                inAppContentBlocksPlaceholders: config.inAppContentBlockPlaceholdersAutoLoad,
                flushingSetup: config.flushingSetup,
                allowDefaultCustomerProperties: config.allowDefaultCustomerProperties,
                advancedAuthEnabled: config.advancedAuthEnabled
            )
            exponeaInstance.pushNotificationsDelegate = self
            exponeaInstance.inAppMessagesDelegate = InAppMessageActionStreamHandler.currentInstance
            result(true)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func isConfigured(with result: FlutterResult) {
        result(exponeaInstance.isConfigured)
    }

    private func getCustomerCookie(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        result(exponeaInstance.customerCookie)
    }

    private func identifyCustomer(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let customer = try ExponeaCustomer(data)
            exponeaInstance.identifyCustomer(customerIds: customer.ids, properties: customer.properties, timestamp: nil)
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func anonymize(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let parser = ConfigurationParser()
            let change = try parser.parseConfigChange(data, defaultBaseUrl: exponeaInstance.configuration!.baseUrl)
            if let project = change.project {
                exponeaInstance.anonymize(exponeaProject: project, projectMapping: change.mapping)
            } else {
                exponeaInstance.anonymize()
            }
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func getDefaultProperties(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        result(exponeaInstance.defaultProperties)
    }

    private func setDefaultProperties(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let props = try JsonDataParser.parse(dictionary: data)
            exponeaInstance.defaultProperties = props
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func flush(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        exponeaInstance.flushData()
        result(nil)
    }

    private func getFlushMode(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let encoder = FlushModeEncoder()
        let mode = encoder.encode(exponeaInstance.flushingMode)
        result(mode)
    }

    private func setFlushMode(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let encoder = FlushModeEncoder()
        do {
            let data = args as! String
            let mode = try encoder.decode(data)
            exponeaInstance.flushingMode = mode
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func getFlushPeriod(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        switch exponeaInstance.flushingMode {
        case .periodic(let period):
            result(period)
        default:
            let error = FlutterError(code: errorCode, message: ExponeaError.flushModeNotPeriodic.localizedDescription, details: nil)
            result(error)
        }
    }

    private func setFlushPeriod(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let period = args as! Int
        switch exponeaInstance.flushingMode {
        case .periodic:
            exponeaInstance.flushingMode = .periodic(period)
            result(nil)
        default:
            let error = FlutterError(code: errorCode, message: ExponeaError.flushModeNotPeriodic.localizedDescription, details: nil)
            result(error)
        }
    }

    private func trackEvent(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let event = try ExponeaEvent(data)
            exponeaInstance.trackEvent(properties: event.properties, timestamp: event.timestamp, eventType: event.name)
            result(nil)
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func trackSessionStart(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let timestamp = args as? Double
        guard timestamp == nil else {
            let error = FlutterError(code: errorCode, message: ExponeaError.notAvailableForPlatform(name: "Setting session start timestamp").localizedDescription, details: nil)
            result(error)
            return
        }
        exponeaInstance.trackSessionStart()
        result(nil)
    }

    private func trackSessionEnd(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let timestamp = args as? Double
        guard timestamp == nil else {
            let error = FlutterError(code: errorCode, message: ExponeaError.notAvailableForPlatform(name: "Setting session start timestamp").localizedDescription, details: nil)
            result(error)
            return
        }
        exponeaInstance.trackSessionEnd()
        result(nil)
    }

    private func fetchConsents(with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        exponeaInstance.fetchConsents { fetchResult in
            switch fetchResult {
            case .success(let response):
                let outData = response.consents.map { ConsentEncoder.encode($0) }
                result(outData)
            case .failure(let error):
                let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                result(error)
            }
        }
    }

    private func fetchRecommendations(_ args: Any?, with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        do {
            let data = args as! [String:Any?]
            let options = try RecommendationOptionsEncoder.decode(data)
            exponeaInstance.fetchRecommendation(
                with: options,
                completion: {(fetchResult: Result<RecommendationResponse<AllRecommendationData>>) in
                    switch fetchResult {
                    case .success(let response):
                        guard let responseValue = response.value else {
                            let error = FlutterError(code: errorCode, message: ExponeaError.fetchError(description: "Empty result.").localizedDescription, details: nil)
                            result(error)
                            return
                        }
                        let outData = responseValue.map { $0.userData.formattedData() }
                        result(outData)
                    case .failure(let error):
                        let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
                        result(error)
                    }
                }
            )
        } catch {
            let error = FlutterError(code: errorCode, message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func getLogLevel(with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let encoder = LogLevelEncoder()
        let logLevel = encoder.encode(ExponeaSDK.Exponea.logger.logLevel)
        result(logLevel)
    }

    private func setLogLevel(_ args: Any?, with result: FlutterResult) {
        guard requireConfigured(with: result) else { return }
        let encoder = LogLevelEncoder()
        do {
            let data = args as! String
            let logLevel = try encoder.decode(data)
            ExponeaSDK.Exponea.logger.logLevel = logLevel
            result(nil)
        } catch {
            let error = FlutterError(code: "2", message: error.localizedDescription, details: nil)
            result(error)
        }
    }

    private func checkPushSetup(with result: FlutterResult) {
        guard requireNotConfigured(with: result) else { return }
        exponeaInstance.checkPushSetup = true
        result(nil)
    }

    private func requestPushAuthorization(with result: @escaping FlutterResult) {
        guard requireConfigured(with: result) else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, _) in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                result(granted)
            }
        }
    }

    private func requireNotConfigured(with result: FlutterResult) -> Bool {
        guard !exponeaInstance.isConfigured else {
            let error = FlutterError(code: "2", message: ExponeaError.alreadyConfigured.localizedDescription, details: nil)
            result(error)
            return false
        }
        return true
    }

    private func requireConfigured(with result: FlutterResult) -> Bool {
        guard exponeaInstance.isConfigured else {
            let error = FlutterError(code: errorCode, message: ExponeaError.notConfigured.localizedDescription, details: nil)
            result(error)
            return false
        }
        return true
    }

}

extension SwiftExponeaPlugin: PushNotificationManagerDelegate {
    public func pushNotificationOpened(
        with action: ExponeaNotificationActionType,
        value: String?,
        extraData: [AnyHashable: Any]?
    ) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: extraData ?? [:], options: []),
              let rawData = try? JSONDecoder.snakeCase.decode(RawData.self, from: jsonData) else {
            ExponeaSDK.Exponea.logger.log(.error, message: "Unable to serialize opened push.")
            return
        }

        let openedPush = OpenedPush(
            action: PushAction.from(actionType: action),
            url: value,
            data: rawData.data
        )
        _ = OpenedPushStreamHandler.handle(push: openedPush)
    }

    public func silentPushNotificationReceived(extraData: [AnyHashable: Any]?) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: extraData ?? [:], options: []),
              let rawData = try? JSONDecoder.snakeCase.decode(RawData.self, from: jsonData) else {
            ExponeaSDK.Exponea.logger.log(.error, message: "Unable to serialize opened push.")
            return
        }

        let receivedPush = ReceivedPush(data: rawData.data)
        _ = ReceivedPushStreamHandler.handle(push: receivedPush)
    }

    @objc
    public static func handlePushNotificationToken(deviceToken: Data) {
        ExponeaSDK.Exponea.shared.handlePushNotificationToken(deviceToken: deviceToken)
    }

    @objc
    public static func handlePushNotificationOpened(userInfo: [AnyHashable: Any]) {
        ExponeaSDK.Exponea.shared.handlePushNotificationOpened(userInfo: userInfo)
    }

    @objc
    public static func handlePushNotificationOpened(response: UNNotificationResponse) {
        ExponeaSDK.Exponea.shared.handlePushNotificationOpened(response: response)
    }

    @objc
    static func continueUserActivity(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
            else { return }
        ExponeaSDK.Exponea.shared.trackCampaignClick(url: incomingURL, timestamp: nil)
    }
}

extension PushAction {
    static func from(actionType: ExponeaNotificationActionType) -> PushAction {
        switch actionType {
        case .none: return .app
        case .openApp: return .app
        case .deeplink: return .deeplink
        case .browser: return .web
        case .selfCheck: return .app
        }
    }
}
