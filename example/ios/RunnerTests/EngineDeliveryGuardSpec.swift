import Foundation
import Quick
import Nimble
import UIKit

@testable import exponea

class EngineDeliveryGuardSpec: QuickSpec {
    override func spec() {
        describe("isSafeToDeliver") {
            it("returns true for active and inactive states") {
                expect(EngineDeliveryGuard.isSafeToDeliver(.active)).to(beTrue())
                expect(EngineDeliveryGuard.isSafeToDeliver(.inactive)).to(beTrue())
            }

            it("returns false for background state") {
                expect(EngineDeliveryGuard.isSafeToDeliver(.background)).to(beFalse())
            }
        }

        describe("detachStreamHandlersFromEngine") {
            it("clears active stream handler sinks") {
                let handler = OpenedPushStreamHandler.newInstance()
                handler.onListen(withArguments: nil, eventSink: { _ in })

                EngineDeliveryGuard.detachStreamHandlersFromEngine()

                var received = false
                handler.onListen(withArguments: nil, eventSink: { _ in
                    received = true
                })
                let handled = OpenedPushStreamHandler.handle(push: OpenedPush(action: .app))

                expect(handled).to(beTrue())
                expect(received).to(beTrue())
                handler.onCancel(withArguments: nil)
            }

            it("clears pending push data so it is not replayed after reconnect") {
                EngineDeliveryGuard.applicationStateProvider = { .background }
                _ = OpenedPushStreamHandler.handle(push: OpenedPush(action: .app))

                EngineDeliveryGuard.detachStreamHandlersFromEngine()

                EngineDeliveryGuard.applicationStateProvider = { .active }
                let handler = OpenedPushStreamHandler.newInstance()
                var received = false
                handler.onListen(withArguments: nil, eventSink: { _ in
                    received = true
                })

                expect(received).to(beFalse())
                handler.onCancel(withArguments: nil)
            }
        }
    }
}
