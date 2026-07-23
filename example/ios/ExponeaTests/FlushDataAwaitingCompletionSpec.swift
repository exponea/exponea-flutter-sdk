//
//  FlushDataAwaitingCompletionSpec.swift
//  ExponeaTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

class FlushDataAwaitingCompletionSpec: QuickSpec {
    override func spec() {
        describe("awaitFlushCompletion") {
            it("forwards .success exactly once when native completion succeeds on the first attempt") {
                var operationCalls = 0
                var deliveredResults: [FlushResult] = []
                waitUntil(timeout: .seconds(2)) { done in
                    SwiftExponeaPlugin.awaitFlushCompletion(
                        flushOperation: { completion in
                            operationCalls += 1
                            DispatchQueue.main.async { completion(.success(1)) }
                        },
                        attemptsRemaining: 5,
                        retryDelay: .milliseconds(10),
                        onComplete: { flushResult in
                            deliveredResults.append(flushResult)
                            done()
                        }
                    )
                }
                expect(operationCalls).to(equal(1))
                expect(deliveredResults).to(haveCount(1))
                if case .success(let count) = deliveredResults.first {
                    expect(count).to(equal(1))
                } else {
                    fail("expected .success, got \(String(describing: deliveredResults.first))")
                }
            }

            it("forwards each non-retry result unchanged through onComplete") {
                let nonRetryResults: [FlushResult] = [
                    .success(0),
                    .noInternetConnection,
                    .error(NSError(domain: "test", code: 1))
                ]
                for stubbedResult in nonRetryResults {
                    var operationCalls = 0
                    var deliveredResult: FlushResult?
                    waitUntil(timeout: .seconds(2)) { done in
                        SwiftExponeaPlugin.awaitFlushCompletion(
                            flushOperation: { completion in
                                operationCalls += 1
                                DispatchQueue.main.async { completion(stubbedResult) }
                            },
                            attemptsRemaining: 5,
                            retryDelay: .milliseconds(10),
                            onComplete: { flushResult in
                                deliveredResult = flushResult
                                done()
                            }
                        )
                    }
                    expect(operationCalls).to(equal(1))
                    switch (deliveredResult, stubbedResult) {
                    case (.success(let delivered), .success(let expected)):
                        expect(delivered).to(equal(expected))
                    case (.noInternetConnection, .noInternetConnection):
                        break
                    case (.error, .error):
                        break
                    default:
                        fail("result \(String(describing: deliveredResult)) did not match stubbed \(stubbedResult)")
                    }
                }
            }

            it("retries while native returns flushAlreadyInProgress and completes when the flush settles") {
                var operationCalls = 0
                var deliveredResult: FlushResult?
                waitUntil(timeout: .seconds(3)) { done in
                    SwiftExponeaPlugin.awaitFlushCompletion(
                        flushOperation: { completion in
                            operationCalls += 1
                            let response: FlushResult = operationCalls < 3
                                ? .flushAlreadyInProgress
                                : .success(2)
                            DispatchQueue.main.async { completion(response) }
                        },
                        attemptsRemaining: 5,
                        retryDelay: .milliseconds(10),
                        onComplete: { flushResult in
                            deliveredResult = flushResult
                            done()
                        }
                    )
                }
                expect(operationCalls).to(equal(3))
                if case .success(let count) = deliveredResult {
                    expect(count).to(equal(2))
                } else {
                    fail("expected .success(2), got \(String(describing: deliveredResult))")
                }
            }

            it("bounds retries and reports flushAlreadyInProgress once the attempt budget is exhausted") {
                var operationCalls = 0
                var deliveredResult: FlushResult?
                waitUntil(timeout: .seconds(3)) { done in
                    SwiftExponeaPlugin.awaitFlushCompletion(
                        flushOperation: { completion in
                            operationCalls += 1
                            DispatchQueue.main.async { completion(.flushAlreadyInProgress) }
                        },
                        attemptsRemaining: 3,
                        retryDelay: .milliseconds(10),
                        onComplete: { flushResult in
                            deliveredResult = flushResult
                            done()
                        }
                    )
                }
                expect(operationCalls).to(equal(4))
                if case .flushAlreadyInProgress = deliveredResult {
                    // expected branch
                } else {
                    fail("expected .flushAlreadyInProgress, got \(String(describing: deliveredResult))")
                }
            }
        }
    }
}

