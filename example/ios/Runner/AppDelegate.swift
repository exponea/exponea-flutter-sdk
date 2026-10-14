import ExponeaSDK
import Flutter
import UIKit
import UserNotifications
import exponea

struct SdkLogEntry {
  let timestamp: Int
  let level: String
  let tag: String
  let message: String

  var wireMap: [String: Any] {
    [
      "timestamp": timestamp,
      "level": level,
      "tag": tag,
      "message": message,
    ]
  }
}

final class ExampleMemoryLogger: Logger {
  private var entries: [SdkLogEntry] = []
  private let lock = NSLock()

  override func log(
    _ level: LogLevel,
    message: String,
    fileName: String = #file,
    line: Int = #line,
    funcName: String = #function
  ) -> Bool {
    guard logLevel.rawValue >= level.rawValue else {
      return false
    }

    let tag = sourceFile(from: fileName)
    let wireLevel: String
    switch level {
    case .verbose:
      wireLevel = "verbose"
    case .warning:
      wireLevel = "warn"
    case .error:
      wireLevel = "error"
    case .none:
      wireLevel = "info"
    }

    let entry = SdkLogEntry(
      timestamp: Int(Date().timeIntervalSince1970 * 1000),
      level: wireLevel,
      tag: tag,
      message: message
    )

    lock.lock()
    entries.append(entry)
    if entries.count > 500 {
      entries.removeFirst(entries.count - 500)
    }
    lock.unlock()

    SdkLogBridge.shared.emit(entry)
    return super.log(level, message: message, fileName: fileName, line: line, funcName: funcName)
  }

  func snapshot() -> [SdkLogEntry] {
    lock.lock()
    defer { lock.unlock() }
    return entries
  }

  func clear() {
    lock.lock()
    entries.removeAll()
    lock.unlock()
  }
}

final class SdkLogBridge: NSObject, FlutterStreamHandler {
  static let shared = SdkLogBridge()

  private var eventSink: FlutterEventSink?

  func register(with messenger: FlutterBinaryMessenger) {
    let eventChannel = FlutterEventChannel(
      name: "exponea_example/sdk_logs",
      binaryMessenger: messenger
    )
    eventChannel.setStreamHandler(self)

    let controlChannel = FlutterMethodChannel(
      name: "exponea_example/sdk_logs_control",
      binaryMessenger: messenger
    )
    controlChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "clear":
        AppDelegate.memoryLogger.clear()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func emit(_ entry: SdkLogEntry) {
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(entry.wireMap)
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    for entry in AppDelegate.memoryLogger.snapshot() {
      events(entry.wireMap)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}

/// Parses cold-start URLs from launch options (custom scheme + universal link).
enum DeeplinkLaunchOptions {
  static func url(from launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> URL? {
    guard let launchOptions else {
      return nil
    }
    if let url = launchOptions[.url] as? URL {
      return url
    }
    if let activityDictionary = launchOptions[.userActivityDictionary] as? [AnyHashable: Any] {
      for value in activityDictionary.values {
        guard let activity = value as? NSUserActivity,
              let url = activity.webpageURL else {
          continue
        }
        return url
      }
    }
    return nil
  }
}

/// Forwards incoming links to Dart via AppDelegate + UIScene plugin hooks and tracks
/// custom-scheme (`exponea://`) campaign clicks. Universal links are tracked by
/// `SwiftExponeaPlugin`, so they are only forwarded here.
final class ExampleDeeplinkHostPlugin: NSObject, FlutterPlugin, FlutterApplicationLifeCycleDelegate,
  FlutterSceneLifeCycleDelegate
{
  private static let instance = ExampleDeeplinkHostPlugin()

  /// Replaced in tests.
  static var trackCampaignClick: (URL) -> Void = { url in
    Exponea.shared.trackCampaignClick(url: url, timestamp: nil)
  }

  static func handleIncomingURL(
    _ url: URL,
    isUniversalLink: Bool,
    bridge: DeeplinkBridge = .shared
  ) {
    if !isUniversalLink {
      trackCampaignClick(url)
    }
    bridge.ingestLink(url.absoluteString)
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    registrar.addApplicationDelegate(instance)
    registrar.addSceneDelegate(instance)
  }

  func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    Self.handleIncomingURL(url, isUniversalLink: false)
    return false
  }

  func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([Any]) -> Void
  ) -> Bool {
    ingestUniversalLink(from: userActivity)
    return false
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    for context in URLContexts {
      Self.handleIncomingURL(context.url, isUniversalLink: false)
    }
    return false
  }

  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) -> Bool {
    ingestUniversalLink(from: userActivity)
    return false
  }

  private func ingestUniversalLink(from activity: NSUserActivity) {
    guard activity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = activity.webpageURL else {
      return
    }
    Self.handleIncomingURL(url, isUniversalLink: true)
  }
}

/// Captures links that launch the app. The implicit Flutter engine, and with it every plugin,
/// is created after the scene connects, so plugin `scene(_:willConnectTo:options:)` callbacks
/// never see these links.
final class ExampleSceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    for context in connectionOptions.urlContexts {
      ExampleDeeplinkHostPlugin.handleIncomingURL(context.url, isUniversalLink: false)
    }
    for activity in connectionOptions.userActivities
    where activity.activityType == NSUserActivityTypeBrowsingWeb {
      if let url = activity.webpageURL {
        ExampleDeeplinkHostPlugin.handleIncomingURL(url, isUniversalLink: true)
      }
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }
}

/// Window root that embeds the storyboard's FlutterViewController as a child.
///
/// The SDK adds rich modal / fullscreen in-app messages as subviews of the root view
/// controller's view. When that view is the FlutterView, Flutter's semantics tree replaces
/// its accessibility children, so those messages are invisible to VoiceOver and XCUITest.
/// A plain container view keeps them as accessible siblings of the FlutterView.
final class ExampleRootViewController: UIViewController {
  private var flutterChild: UIViewController? { children.first }

  override var childForStatusBarStyle: UIViewController? { flutterChild }
  override var childForStatusBarHidden: UIViewController? { flutterChild }
  override var childForHomeIndicatorAutoHidden: UIViewController? { flutterChild }
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    flutterChild?.supportedInterfaceOrientations ?? .all
  }
}

@main
@objc class AppDelegate: ExponeaFlutterAppDelegate, FlutterImplicitEngineDelegate {
  static let memoryLogger = ExampleMemoryLogger()

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Links that launch the app arrive before this engine exists; `ExampleSceneDelegate`
    // captures them. This plugin handles links while the app is running.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ExampleDeeplinkHost") {
      ExampleDeeplinkHostPlugin.register(with: registrar)
    }

    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()
    SdkLogBridge.shared.register(with: messenger)
    DeeplinkBridge.shared.register(with: messenger)
    registerDeviceChannel(with: messenger)
  }

  /// Compile-time simulator check for Dart. `SIMULATOR_*` environment variables are not
  /// present when XCTest relaunches the app, so Dart cannot detect the simulator on its own.
  private func registerDeviceChannel(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "exponea_example/device", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "isSimulator" else {
        result(FlutterMethodNotImplemented)
        return
      }
      #if targetEnvironment(simulator)
      result(true)
      #else
      result(false)
      #endif
    }
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    Exponea.logger = AppDelegate.memoryLogger
    Exponea.logger.logLevel = .verbose
    // CocoaPods often builds ExponeaSDK without DEBUG; enable runtime debug so
    // checkPushSetup self-check runs in this example app (Android uses FLAG_DEBUGGABLE).
    Exponea.shared.isDebugModeEnabled = true

    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let url = DeeplinkLaunchOptions.url(from: launchOptions) {
      DeeplinkBridge.shared.ingestLink(url.absoluteString)
    }

    return ok
  }

  /// FlutterAppDelegate returns false from responds(to:) for this selector unless a
  /// plugin registers it. Exponea iOS self-check requires responds(to:) == true.
  override func responds(to aSelector: Selector!) -> Bool {
    if aSelector == #selector(
      application(_:didReceiveRemoteNotification:fetchCompletionHandler:)
    ) {
      return true
    }
    return super.responds(to: aSelector)
  }

  // Required for iOS push self-check (responds(to:) on UIApplicationDelegate).
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    super.application(
      application,
      didReceiveRemoteNotification: userInfo,
      fetchCompletionHandler: completionHandler
    )
  }
}

final class DeeplinkBridge: NSObject {
  static let shared = DeeplinkBridge()

  private var initialLink: String?
  private var deliveredInitial = false
  /// Sends `linkOpened` to Dart; set by `register(with:)`, replaced in tests.
  var send: ((String) -> Void)?

  func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "exponea_example/deeplinks",
      binaryMessenger: messenger
    )
    send = { channel.invokeMethod("linkOpened", arguments: $0) }
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "gone", message: nil, details: nil))
        return
      }
      switch call.method {
      case "getInitialLink":
        result(self.takeInitialLink())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Returns the cold-start link once; later links go through `linkOpened`.
  func takeInitialLink() -> String? {
    deliveredInitial = true
    return initialLink
  }

  /// Each link reaches Dart once: before Dart asked for the initial link it is kept for
  /// `getInitialLink` (a `linkOpened` sent now would be buffered and delivered as a second copy).
  func ingestLink(_ link: String) {
    if !deliveredInitial {
      initialLink = link
      return
    }
    send?(link)
  }
}
