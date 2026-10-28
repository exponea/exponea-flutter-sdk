//
//  RuntimeInAppContentBlockControllerBridgeSpec.swift
//  RunnerTests
//

import Flutter
import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

private final class MockRuntimeController: RuntimeInContentBlockControllerType {
    var prefetchCalls: [(ids: [String], deadline: TimeInterval?)] = []
    var availabilityCalls: [(id: String, deadline: TimeInterval)] = []
    var invalidateCalls: [(ids: [String], reason: String, mode: InAppContentBlockInvalidateMode)] = []

    var prefetchResponder: (@escaping ([String: InAppContentBlockAvailability]) -> Void) -> Void = { _ in }
    var availabilityResponder: (@escaping (InAppContentBlockAvailabilityDecision) -> Void) -> Void = { _ in }

    func prefetch(ids: [String], deadline: TimeInterval?) async -> [String: InAppContentBlockAvailability] {
        [:]
    }

    func prefetch(
        ids: [String],
        deadline: TimeInterval?,
        completion: @escaping ([String: InAppContentBlockAvailability]) -> Void
    ) {
        prefetchCalls.append((ids, deadline))
        prefetchResponder(completion)
    }

    func invalidate(ids: [String], reason: String, mode: InAppContentBlockInvalidateMode) {
        invalidateCalls.append((ids, reason, mode))
    }

    func availability(id: String, deadline: TimeInterval) async -> InAppContentBlockAvailabilityDecision {
        .timedOut
    }

    func availability(
        id: String,
        deadline: TimeInterval,
        completion: @escaping (InAppContentBlockAvailabilityDecision) -> Void
    ) {
        availabilityCalls.append((id, deadline))
        availabilityResponder(completion)
    }
}

private final class ResultRecorder {
    var values: [Any?] = []
    var onMainThread: [Bool] = []

    var result: FlutterResult {
        return { value in
            self.values.append(value)
            self.onMainThread.append(Thread.isMainThread)
        }
    }

    var error: FlutterError? { values.first as? FlutterError }
}

class RuntimeInAppContentBlockControllerBridgeSpec: QuickSpec {
    override func spec() {
        typealias Bridge = RuntimeInAppContentBlockControllerBridge
        let unavailableMessage =
            "RuntimeInAppContentBlockController is unavailable because the Exponea SDK is not configured."

        var controller: MockRuntimeController!
        var recorder: ResultRecorder!

        beforeEach {
            controller = MockRuntimeController()
            recorder = ResultRecorder()
        }

        describe("unavailable controller") {
            it("rejects every call with Unavailable and the RN message") {
                let recorders = [ResultRecorder(), ResultRecorder(), ResultRecorder()]

                Bridge.prefetch(controller: nil, arguments: ["ids": ["a"], "deadlineMs": 1], result: recorders[0].result)
                Bridge.availability(controller: nil, arguments: ["id": "a", "deadlineMs": 1], result: recorders[1].result)
                Bridge.invalidate(
                    controller: nil,
                    arguments: ["ids": ["a"], "reason": "x", "mode": "eager"],
                    result: recorders[2].result
                )

                for recorder in recorders {
                    expect(recorder.values).to(haveCount(1))
                    expect(recorder.error?.code).to(equal("RuntimeInAppContentBlockControllerUnavailable"))
                    expect(recorder.error?.message).to(equal(unavailableMessage))
                }
            }
        }

        describe("prefetch") {
            it("forwards ids, converts ms to seconds and maps the result") {
                controller.prefetchResponder = { completion in
                    completion(["a": .ready, "b": .empty, "c": .loading])
                }

                waitUntil { done in
                    Bridge.prefetch(
                        controller: controller,
                        arguments: ["ids": ["a", "b", "c"], "deadlineMs": 2000],
                        result: { value in
                            recorder.result(value)
                            done()
                        }
                    )
                }

                expect(controller.prefetchCalls.first?.ids).to(equal(["a", "b", "c"]))
                expect(controller.prefetchCalls.first?.deadline).to(equal(2.0))
                expect(recorder.values).to(haveCount(1))
                expect(recorder.values.first as? [String: String])
                    .to(equal(["a": "ready", "b": "empty", "c": "loading"]))
            }

            it("passes a nil deadline when none is given") {
                Bridge.prefetch(controller: controller, arguments: ["ids": ["a"], "deadlineMs": NSNull()], result: recorder.result)
                Bridge.prefetch(controller: controller, arguments: ["ids": ["a"]], result: recorder.result)

                expect(controller.prefetchCalls).to(haveCount(2))
                expect(controller.prefetchCalls[0].deadline).to(beNil())
                expect(controller.prefetchCalls[1].deadline).to(beNil())
            }

            it("completes exactly once on the main thread when native calls back on a background queue") {
                controller.prefetchResponder = { completion in
                    DispatchQueue.global(qos: .userInitiated).async {
                        completion(["a": .ready])
                    }
                }

                waitUntil(timeout: .seconds(5)) { done in
                    Bridge.prefetch(
                        controller: controller,
                        arguments: ["ids": ["a"], "deadlineMs": 2000],
                        result: { value in
                            recorder.result(value)
                            done()
                        }
                    )
                }
                // Give a duplicate delivery the chance to show up.
                waitUntil { done in DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { done() } }

                expect(recorder.values).to(haveCount(1))
                expect(recorder.onMainThread).to(equal([true]))
            }

            it("rejects invalid arguments with Error") {
                Bridge.prefetch(controller: controller, arguments: ["deadlineMs": 1], result: recorder.result)

                expect(recorder.values).to(haveCount(1))
                expect(recorder.error?.code).to(equal("RuntimeInAppContentBlockControllerError"))
                expect(controller.prefetchCalls).to(beEmpty())
            }
        }

        describe("availability") {
            it("maps resolved and timed out decisions") {
                controller.availabilityResponder = { completion in completion(.resolved(.ready)) }
                waitUntil { done in
                    Bridge.availability(
                        controller: controller,
                        arguments: ["id": "a", "deadlineMs": 2000],
                        result: { value in
                            recorder.result(value)
                            done()
                        }
                    )
                }
                controller.availabilityResponder = { completion in completion(.timedOut) }
                waitUntil { done in
                    Bridge.availability(
                        controller: controller,
                        arguments: ["id": "b", "deadlineMs": 2000],
                        result: { value in
                            recorder.result(value)
                            done()
                        }
                    )
                }

                expect(recorder.values[0] as? [String: String])
                    .to(equal(["status": "resolved", "availability": "ready"]))
                expect(recorder.values[1] as? [String: String]).to(equal(["status": "timedOut"]))
            }

            it("converts the deadline from ms to seconds") {
                Bridge.availability(controller: controller, arguments: ["id": "a", "deadlineMs": 2000], result: recorder.result)

                expect(controller.availabilityCalls.first?.id).to(equal("a"))
                expect(controller.availabilityCalls.first?.deadline).to(equal(2.0))
            }

            it("passes zero and negative deadlines through") {
                Bridge.availability(controller: controller, arguments: ["id": "a", "deadlineMs": 0], result: recorder.result)
                Bridge.availability(controller: controller, arguments: ["id": "a", "deadlineMs": -5], result: recorder.result)

                expect(controller.availabilityCalls.map { $0.deadline }).to(equal([0.0, -0.005]))
            }

            it("completes exactly once on the main thread when native calls back on a background queue") {
                controller.availabilityResponder = { completion in
                    DispatchQueue.global(qos: .userInitiated).async { completion(.timedOut) }
                }

                waitUntil(timeout: .seconds(5)) { done in
                    Bridge.availability(
                        controller: controller,
                        arguments: ["id": "a", "deadlineMs": 1],
                        result: { value in
                            recorder.result(value)
                            done()
                        }
                    )
                }
                waitUntil { done in DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { done() } }

                expect(recorder.values).to(haveCount(1))
                expect(recorder.onMainThread).to(equal([true]))
            }
        }

        describe("invalidate") {
            it("completes immediately after the native call") {
                Bridge.invalidate(
                    controller: controller,
                    arguments: ["ids": ["a"], "reason": "x", "mode": "eager"],
                    result: recorder.result
                )

                expect(controller.invalidateCalls).to(haveCount(1))
                expect(controller.invalidateCalls.first?.ids).to(equal(["a"]))
                expect(controller.invalidateCalls.first?.reason).to(equal("x"))
                expect(controller.invalidateCalls.first?.mode).to(equal(.eager))
                expect(recorder.values).to(haveCount(1))
                expect(recorder.values.first ?? "not nil").to(beNil())
            }

            it("matches the mode case-insensitively") {
                Bridge.invalidate(
                    controller: controller,
                    arguments: ["ids": ["a"], "reason": "x", "mode": "EAGER"],
                    result: recorder.result
                )
                Bridge.invalidate(
                    controller: controller,
                    arguments: ["ids": ["b"], "reason": "y", "mode": "Lazy"],
                    result: recorder.result
                )

                expect(controller.invalidateCalls.map { $0.mode }).to(equal([.eager, .lazy]))
            }

            it("rejects an unknown mode with InvalidMode") {
                Bridge.invalidate(
                    controller: controller,
                    arguments: ["ids": ["a"], "reason": "x", "mode": "bogus"],
                    result: recorder.result
                )

                expect(recorder.values).to(haveCount(1))
                expect(recorder.error?.code).to(equal("RuntimeInAppContentBlockControllerInvalidMode"))
                expect(recorder.error?.message)
                    .to(equal("Unknown RuntimeInAppContentBlockController invalidate mode: bogus"))
                expect(controller.invalidateCalls).to(beEmpty())
            }
        }
    }
}
