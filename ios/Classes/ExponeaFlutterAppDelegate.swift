//
//  ExponeaFlutterAppDelegate.swift
//  exponea
//

import Foundation
import UIKit
import Flutter
import ExponeaSDK

open class ExponeaFlutterAppDelegate: FlutterAppDelegate {

    /// Sets `UNUserNotificationCenter.current().delegate` to `self`.
    ///
    /// Called automatically from `application(_:didFinishLaunchingWithOptions:)` before `super`.
    /// Override that method and call this at the start (before `super`) if you need custom launch
    /// logic. If you do not extend `ExponeaFlutterAppDelegate`, call
    /// `SwiftExponeaPlugin.setUserNotificationCenterDelegate(_:)` instead.
    @objc open func configurePushNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }

    @discardableResult
    open override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configurePushNotificationDelegate()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    open override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        SwiftExponeaPlugin.handlePushNotificationToken(deviceToken: deviceToken)
    }
    
    // only this method is called in flutter ios app
    open override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) {
        SwiftExponeaPlugin.handlePushNotificationOpened(userInfo: userInfo)
    }
    
    // this method is never called in flutter ios app use ^ instead
    // github issue : https://github.com/flutter/flutter/issues/52895
    // BUT this method must be implemented cause otherwise ExponeaSDK will complain even though it's never really called
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
    
    open override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // show notification even if the app is in the foreground
        if #available(iOS 14, *) {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }

    // Sole legacy-path Universal Link entry point. SwiftExponeaPlugin intentionally does not
    // implement application(_:continue:) (to avoid double-firing with this override); UIScene
    // apps receive links via FlutterSceneLifeCycleDelegate instead.
    open override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        SwiftExponeaPlugin.continueUserActivity(userActivity)
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}
