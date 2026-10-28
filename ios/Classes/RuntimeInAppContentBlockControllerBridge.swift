import ExponeaSDK
import Flutter
import Foundation

/// Bridges the runtime in-app content block controller channel methods.
///
/// The plugin passes the native controller on every call, so tests can pass a mock
/// `RuntimeInContentBlockControllerType`. Error codes and messages match the React Native SDK.
/// Completions capture nothing but the controller and `result`, and always reply on main.
enum RuntimeInAppContentBlockControllerBridge {
    private static let errorUnavailable = "RuntimeInAppContentBlockControllerUnavailable"
    private static let errorInvalidMode = "RuntimeInAppContentBlockControllerInvalidMode"
    private static let error = "RuntimeInAppContentBlockControllerError"

    static func prefetch(
        controller: RuntimeInContentBlockControllerType?,
        arguments: Any?,
        result: @escaping FlutterResult
    ) {
        guard let controller = requireController(controller, result: result) else { return }
        guard let data = arguments as? [String: Any], let ids = data["ids"] as? [String] else {
            result(invalidArguments(arguments))
            return
        }
        // Dart sends milliseconds; the native deadline is a TimeInterval in seconds.
        let deadline = (data["deadlineMs"] as? NSNumber).map { $0.doubleValue / 1000 }
        controller.prefetch(ids: ids, deadline: deadline) { availabilities in
            let mapped = availabilities.mapValues(bridgeValue)
            DispatchQueue.main.async {
                result(mapped)
            }
        }
    }

    static func availability(
        controller: RuntimeInContentBlockControllerType?,
        arguments: Any?,
        result: @escaping FlutterResult
    ) {
        guard let controller = requireController(controller, result: result) else { return }
        guard let data = arguments as? [String: Any],
              let id = data["id"] as? String,
              let deadlineMs = data["deadlineMs"] as? NSNumber else {
            result(invalidArguments(arguments))
            return
        }
        controller.availability(id: id, deadline: deadlineMs.doubleValue / 1000) { decision in
            let mapped: [String: String]
            switch decision {
            case .resolved(let availability):
                mapped = ["status": "resolved", "availability": bridgeValue(availability)]
            case .timedOut:
                mapped = ["status": "timedOut"]
            }
            DispatchQueue.main.async {
                result(mapped)
            }
        }
    }

    static func invalidate(
        controller: RuntimeInContentBlockControllerType?,
        arguments: Any?,
        result: @escaping FlutterResult
    ) {
        guard let controller = requireController(controller, result: result) else { return }
        guard let data = arguments as? [String: Any],
              let ids = data["ids"] as? [String],
              let reason = data["reason"] as? String,
              let mode = data["mode"] as? String else {
            result(invalidArguments(arguments))
            return
        }
        let nativeMode: InAppContentBlockInvalidateMode
        switch mode.lowercased() {
        case "eager":
            nativeMode = .eager
        case "lazy":
            nativeMode = .lazy
        default:
            result(FlutterError(
                code: errorInvalidMode,
                message: "Unknown RuntimeInAppContentBlockController invalidate mode: \(mode)",
                details: nil
            ))
            return
        }
        controller.invalidate(ids: ids, reason: reason, mode: nativeMode)
        result(nil)
    }

    private static func requireController(
        _ controller: RuntimeInContentBlockControllerType?,
        result: FlutterResult
    ) -> RuntimeInContentBlockControllerType? {
        guard let controller else {
            result(FlutterError(
                code: errorUnavailable,
                message: "RuntimeInAppContentBlockController is unavailable because the Exponea SDK is not configured.",
                details: nil
            ))
            return nil
        }
        return controller
    }

    private static func invalidArguments(_ arguments: Any?) -> FlutterError {
        FlutterError(code: error, message: "Invalid arguments: \(String(describing: arguments))", details: nil)
    }

    private static func bridgeValue(_ availability: InAppContentBlockAvailability) -> String {
        switch availability {
        case .ready: return "ready"
        case .empty: return "empty"
        case .loading: return "loading"
        }
    }
}
