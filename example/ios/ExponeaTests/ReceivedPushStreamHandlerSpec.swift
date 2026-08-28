import Foundation
import Quick
import Nimble
import UIKit

@testable import exponea

class ReceivedPushStreamHandlerSpec: QuickSpec {
    override func spec() {
        let defaultStateProvider = EngineDeliveryGuard.applicationStateProvider
        let push = ReceivedPush(data: ["test": true])

        afterEach {
            EngineDeliveryGuard.applicationStateProvider = defaultStateProvider
        }

        describe("delivery guard") {
            it("delivers to sink when app state is safe") {
                EngineDeliveryGuard.applicationStateProvider = { .active }
                let handler = ReceivedPushStreamHandler.newInstance()
                var received: [String: Any?]? = nil
                handler.onListen(withArguments: nil, eventSink: { event in
                    received = event as? [String: Any?]
                })

                let handled = ReceivedPushStreamHandler.handle(push: push)

                expect(handled).to(beTrue())
                expect(received).toNot(beNil())
                handler.onCancel(withArguments: nil)
            }

            it("queues push as pendingData when delivery is unsafe even with an active sink") {
                EngineDeliveryGuard.applicationStateProvider = { .active }
                let handler = ReceivedPushStreamHandler.newInstance()
                handler.onListen(withArguments: nil, eventSink: { _ in })

                EngineDeliveryGuard.applicationStateProvider = { .background }
                var receivedWhileBackground = false
                handler.onListen(withArguments: nil, eventSink: { _ in
                    receivedWhileBackground = true
                })

                let handled = ReceivedPushStreamHandler.handle(push: push)

                expect(handled).to(beFalse())
                expect(receivedWhileBackground).to(beFalse())
                handler.onCancel(withArguments: nil)
            }

            it("flushes pending push on onListen after unsafe delivery") {
                EngineDeliveryGuard.applicationStateProvider = { .background }
                _ = ReceivedPushStreamHandler.handle(push: push)

                EngineDeliveryGuard.applicationStateProvider = { .active }
                let handler = ReceivedPushStreamHandler.newInstance()
                var received = false
                handler.onListen(withArguments: nil, eventSink: { _ in
                    received = true
                })

                expect(received).to(beTrue())
                handler.onCancel(withArguments: nil)
            }
        }
    }
}
