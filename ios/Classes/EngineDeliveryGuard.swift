import UIKit

enum EngineDeliveryGuard {
    static var applicationStateProvider: () -> UIApplication.State = {
        UIApplication.shared.applicationState
    }

    // Treats .inactive as safe so events can be queued during foreground transitions.
    // If flaky engine-teardown crashes appear, consider narrowing this to .active only.
    static func isSafeToDeliver(_ state: UIApplication.State) -> Bool {
        state != .background
    }

    static func isSafeToDeliver() -> Bool {
        isSafeToDeliver(applicationStateProvider())
    }

    static func detachStreamHandlersFromEngine() {
        OpenedPushStreamHandler.detachFromEngine()
        ReceivedPushStreamHandler.detachFromEngine()
        SegmentationDataStreamHandler.detachFromEngine()
        InAppMessageActionStreamHandler.currentInstance.detachFromEngine()
    }
}
