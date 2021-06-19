import Foundation
import UIKit
import Flutter
import exponea

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    @discardableResult
    open override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        // process push notification from launch options - when app is not running while push is received
        if let launchOptions = launchOptions,
           let userInfo = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            SwiftExponeaPlugin.handlePushNotificationOpened(userInfo: userInfo)
        }
        UNUserNotificationCenter.current().delegate = self
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    open override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        SwiftExponeaPlugin.handlePushNotificationToken(deviceToken: deviceToken)
    }

    open override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        SwiftExponeaPlugin.handlePushNotificationOpened(userInfo: userInfo)
        completionHandler(.newData)
    }

    open override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        SwiftExponeaPlugin.handlePushNotificationOpened(response: response)
        completionHandler()
    }
    
    open override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // TODO-EXF-8 : SwiftExponeaPlugin.continueUserActivity()
        return false
    }
}
