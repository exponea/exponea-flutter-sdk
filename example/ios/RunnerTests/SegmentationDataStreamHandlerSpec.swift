import Foundation
import Quick
import Nimble
import UIKit

@testable import ExponeaSDK
@testable import exponea

class SegmentationDataStreamHandlerSpec: QuickSpec {
    override func spec() {
        let defaultStateProvider = EngineDeliveryGuard.applicationStateProvider
        let segmentationData = SegmentationData(
            instanceId: "instance-1",
            data: [SegmentDTO(id: "segment-id", segmentationId: "segmentation-id")]
        )

        afterEach {
            EngineDeliveryGuard.applicationStateProvider = defaultStateProvider
        }

        describe("delivery guard") {
            it("delivers to sink when app state is safe") {
                EngineDeliveryGuard.applicationStateProvider = { .active }
                let handler = SegmentationDataStreamHandler.newInstance()
                var received: [String: Any]? = nil
                handler.onListen(withArguments: nil, eventSink: { event in
                    received = event as? [String: Any]
                })

                let handled = SegmentationDataStreamHandler.handle(segmentationData: segmentationData)

                expect(handled).to(beTrue())
                expect(received).toNot(beNil())
                handler.onCancel(withArguments: nil)
            }

            it("queues data as pendingData when delivery is unsafe even with an active sink") {
                EngineDeliveryGuard.applicationStateProvider = { .active }
                let handler = SegmentationDataStreamHandler.newInstance()
                handler.onListen(withArguments: nil, eventSink: { _ in })

                EngineDeliveryGuard.applicationStateProvider = { .background }
                var receivedWhileBackground = false
                handler.onListen(withArguments: nil, eventSink: { _ in
                    receivedWhileBackground = true
                })

                let handled = SegmentationDataStreamHandler.handle(segmentationData: segmentationData)

                expect(handled).to(beFalse())
                expect(receivedWhileBackground).to(beFalse())
                handler.onCancel(withArguments: nil)
            }

            it("flushes pending data on onListen after unsafe delivery") {
                EngineDeliveryGuard.applicationStateProvider = { .background }
                _ = SegmentationDataStreamHandler.handle(segmentationData: segmentationData)

                EngineDeliveryGuard.applicationStateProvider = { .active }
                let handler = SegmentationDataStreamHandler.newInstance()
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
