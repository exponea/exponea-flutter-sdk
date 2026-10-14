import Foundation
import Quick
import Nimble
import UserNotifications

@testable import exponea

private final class TestPushAppDelegate: ExponeaFlutterAppDelegate {}

class ExponeaFlutterAppDelegateSpec: QuickSpec {
    override func spec() {
        describe("configurePushNotificationDelegate") {
            it("sets UNUserNotificationCenter delegate to self") {
                let delegate = TestPushAppDelegate()
                delegate.configurePushNotificationDelegate()

                expect(UNUserNotificationCenter.current().delegate).to(beIdenticalTo(delegate))
            }
        }

        describe("application(_:didFinishLaunchingWithOptions:)") {
            it("configures UNUserNotificationCenter delegate automatically for bare subclasses") {
                let delegate = TestPushAppDelegate()
                _ = delegate.application(
                    UIApplication.shared,
                    didFinishLaunchingWithOptions: nil
                )

                expect(UNUserNotificationCenter.current().delegate).to(beIdenticalTo(delegate))
            }
        }

        describe("SwiftExponeaPlugin.setUserNotificationCenterDelegate") {
            it("sets UNUserNotificationCenter delegate to the provided delegate") {
                let delegate = TestPushAppDelegate()
                SwiftExponeaPlugin.setUserNotificationCenterDelegate(delegate)

                expect(UNUserNotificationCenter.current().delegate).to(beIdenticalTo(delegate))
            }
        }
    }
}
