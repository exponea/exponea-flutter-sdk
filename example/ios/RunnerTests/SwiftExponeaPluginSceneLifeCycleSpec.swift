import Foundation
import Quick
import Nimble
import UIKit

@testable import exponea

class SwiftExponeaPluginSceneLifeCycleSpec: QuickSpec {
    override func spec() {
        describe("FlutterSceneLifeCycleDelegate return values") {
            var plugin: SwiftExponeaPlugin!
            var scene: UIScene!
            var session: UISceneSession!

            beforeEach {
                plugin = SwiftExponeaPlugin()
                let windowScene = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first
                guard let windowScene else {
                    fail("Expected a connected UIWindowScene in the test host app")
                    return
                }
                scene = windowScene
                session = windowScene.session
            }

            it("returns false from scene(_:willConnectTo:options:)") {
                let result = plugin.scene(
                    scene,
                    willConnectTo: session,
                    options: nil
                )
                expect(result).to(beFalse())
            }

            it("returns false from scene(_:continue:) for browsing-web activities") {
                let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                activity.webpageURL = URL(string: "https://example.com/campaign")

                let result = plugin.scene(scene, continue: activity)
                expect(result).to(beFalse())
            }

            it("returns false from scene(_:continue:) for non-browsing-web activities") {
                let activity = NSUserActivity(activityType: "com.example.other")

                let result = plugin.scene(scene, continue: activity)
                expect(result).to(beFalse())
            }

            it("clears stream handler sinks on sceneDidDisconnect") {
                let openedHandler = OpenedPushStreamHandler.newInstance()
                openedHandler.onListen(withArguments: nil, eventSink: { _ in })

                plugin.sceneDidDisconnect(scene)

                var received = false
                openedHandler.onListen(withArguments: nil, eventSink: { _ in
                    received = true
                })
                _ = OpenedPushStreamHandler.handle(push: OpenedPush(action: .app))

                expect(received).to(beTrue())
                openedHandler.onCancel(withArguments: nil)
            }
        }

        describe("browsingWebUserActivity") {
            it("returns the first browsing-web activity with a webpage URL") {
                let activityWithURL = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                activityWithURL.webpageURL = URL(string: "https://example.com/campaign")

                let selected = SwiftExponeaPlugin.browsingWebUserActivity(
                    from: [activityWithURL]
                )

                expect(selected).to(beIdenticalTo(activityWithURL))
            }

            it("skips browsing-web activities without a webpage URL") {
                let activityWithoutURL = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                let activityWithURL = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                activityWithURL.webpageURL = URL(string: "https://example.com/campaign")

                let selected = SwiftExponeaPlugin.browsingWebUserActivity(
                    from: [activityWithoutURL, activityWithURL]
                )

                expect(selected).to(beIdenticalTo(activityWithURL))
            }
        }

        describe("continueUserActivity") {
            it("ignores non-browsing-web activities") {
                let activity = NSUserActivity(activityType: "com.example.other")
                SwiftExponeaPlugin.continueUserActivity(activity)
                // No assertion on SDK side; test verifies the guard does not trap.
            }

            it("accepts browsing-web activities with a webpage URL") {
                let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                activity.webpageURL = URL(string: "https://example.com/campaign")
                SwiftExponeaPlugin.continueUserActivity(activity)
                // No assertion on SDK side; test verifies the guard does not trap.
            }
        }
    }
}
