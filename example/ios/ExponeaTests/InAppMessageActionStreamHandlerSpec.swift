import Foundation
import Quick
import Nimble
import UIKit

@testable import exponea

class InAppMessageActionStreamHandlerSpec: QuickSpec {
    override func spec() {
        let defaultStateProvider = EngineDeliveryGuard.applicationStateProvider
        let handler = InAppMessageActionStreamHandler.currentInstance

        afterEach {
            EngineDeliveryGuard.applicationStateProvider = defaultStateProvider
            handler.onCancel(withArguments: nil)
        }

        describe("delivery guard") {
            it("delivers to sink when app state is safe") {
                EngineDeliveryGuard.applicationStateProvider = { .active }
                var received: [String: Any?]? = nil
                handler.onListen(withArguments: nil, eventSink: { event in
                    received = event as? [String: Any?]
                })

                handler.inAppMessageError(message: nil, errorMessage: "test-error")

                expect(received).toNot(beNil())
                expect(received?["errorMessage"] as? String).to(equal("test-error"))
            }

            it("queues action as pendingData when delivery is unsafe even with an active sink") {
                EngineDeliveryGuard.applicationStateProvider = { .active }
                handler.onListen(withArguments: nil, eventSink: { _ in })

                EngineDeliveryGuard.applicationStateProvider = { .background }
                var receivedWhileBackground = false
                handler.onListen(withArguments: nil, eventSink: { _ in
                    receivedWhileBackground = true
                })

                handler.inAppMessageError(message: nil, errorMessage: "queued-error")

                expect(receivedWhileBackground).to(beFalse())
            }

            it("flushes pending action on onListen after unsafe delivery") {
                EngineDeliveryGuard.applicationStateProvider = { .background }
                handler.inAppMessageError(message: nil, errorMessage: "queued-error")

                EngineDeliveryGuard.applicationStateProvider = { .active }
                var receivedError: String? = nil
                handler.onListen(withArguments: nil, eventSink: { event in
                    let map = event as? [String: Any?]
                    receivedError = map?["errorMessage"] as? String
                })

                expect(receivedError).to(equal("queued-error"))
            }
        }
    }
}
