//
//  ContentBlockCarouselSelectionBridgeSpec.swift
//  RunnerTests
//

import Foundation
import Quick
import Nimble

@testable import ExponeaSDK
@testable import exponea

private func contentBlock(_ id: String) -> InAppContentBlockResponse {
    let json = """
    {"id": "\(id)", "name": "Block \(id)", "date_filter": {"enabled": false}, "placeholders": ["example_carousel"]}
    """
    return try! JSONDecoder().decode(InAppContentBlockResponse.self, from: json.data(using: .utf8)!)
}

private func ids(_ contentBlocks: [InAppContentBlockResponse]?) -> [String]? {
    return contentBlocks?.map { $0.id }
}

private final class InvokeRecorder {
    var calls: [(method: String, ids: [String], onHandled: () -> Void)] = []
    var delivers = true

    var invoke: ContentBlockCarouselSelectionBridge.Invoke {
        return { method, contentBlocks, onHandled in
            self.calls.append((method, contentBlocks.map { $0.id }, onHandled))
            return self.delivers
        }
    }

    /// Simulates Dart finishing the handling of the call at `index`, as the method channel reply does.
    func handled(_ index: Int) {
        calls[index].onHandled()
    }
}

final class ContentBlockCarouselSelectionBridgeSpec: QuickSpec {
    override func spec() {
        let filterMethod = ContentBlockCarouselSelectionBridge.methodFilterContentBlocks
        let sortMethod = ContentBlockCarouselSelectionBridge.methodSortContentBlocks
        let input = ["a", "b", "c"].map(contentBlock)
        var recorder: InvokeRecorder!

        beforeEach {
            recorder = InvokeRecorder()
        }

        func makeBridge(filter: Bool, sort: Bool, timeout: TimeInterval = 5) -> ContentBlockCarouselSelectionBridge {
            return ContentBlockCarouselSelectionBridge(
                filtrationSet: filter,
                sortingSet: sort,
                responseTimeout: timeout,
                invoke: recorder.invoke
            )
        }

        it("completes synchronously without calling Dart when no callback is set") {
            let bridge = makeBridge(filter: false, sort: false)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            expect(ids(result)).to(equal(["a", "b", "c"]))
            expect(recorder.calls).to(beEmpty())
            expect(bridge.applyDartSortOrder(to: [])).to(beNil())
        }

        it("waits for the Dart filter answer and keeps the returned blocks in Dart order") {
            let bridge = makeBridge(filter: true, sort: false)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            expect(recorder.calls.map { $0.method }).to(equal([filterMethod]))
            expect(recorder.calls.first?.ids).to(equal(["a", "b", "c"]))
            expect(result).to(beNil())

            expect(bridge.handleFilterResult(["c", "a"])).to(beTrue())
            expect(ids(result)).to(equal(["c", "a"]))
        }

        it("ignores blocks in the Dart answer that were not in the request") {
            let bridge = makeBridge(filter: true, sort: false)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            bridge.handleFilterResult(["b", "unknown"])
            expect(ids(result)).to(equal(["b"]))
        }

        it("falls back to the unfiltered input when the Dart filter does not answer in time") {
            let bridge = makeBridge(filter: true, sort: false, timeout: 0.05)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            expect(result).to(beNil())
            expect(ids(result)).toEventually(equal(["a", "b", "c"]))
            expect(bridge.handleFilterResult(["a"])).to(beFalse())
        }

        it("falls back immediately when the request cannot be delivered") {
            recorder.delivers = false
            let bridge = makeBridge(filter: true, sort: true)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            expect(ids(result)).to(equal(["a", "b", "c"]))
            expect(recorder.calls.map { $0.method }).to(equal([filterMethod, sortMethod]))
            expect(bridge.applyDartSortOrder(to: [])).to(beNil())
        }

        it("sorts the filtered blocks and exposes the Dart sort order") {
            let bridge = makeBridge(filter: true, sort: true)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            bridge.handleFilterResult(["a", "c"])
            expect(recorder.calls.map { $0.method }).to(equal([filterMethod, sortMethod]))
            expect(recorder.calls.last?.ids).to(equal(["a", "c"]))
            expect(result).to(beNil())

            expect(bridge.handleSortResult(["c", "a"])).to(beTrue())
            expect(ids(result)).to(equal(["c", "a"]))
            let data = ["a", "c"].map { StaticReturnData(html: "", tag: 0, message: contentBlock($0)) }
            expect(bridge.applyDartSortOrder(to: data)?.map { $0.message?.id }).to(equal(["c", "a"]))
        }

        it("leaves sorting to the native SDK when the Dart sort does not answer in time") {
            let bridge = makeBridge(filter: false, sort: true, timeout: 0.05)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            expect(ids(result)).toEventually(equal(["a", "b", "c"]))
            let data = input.map { StaticReturnData(html: "", tag: 0, message: $0) }
            expect(bridge.applyDartSortOrder(to: data)).to(beNil())
        }

        it("runs selections one at a time") {
            let bridge = makeBridge(filter: true, sort: false)
            var first: [InAppContentBlockResponse]?
            var second: [InAppContentBlockResponse]?
            bridge.select(input) { first = $0 }
            bridge.select(["b", "c"].map(contentBlock)) { second = $0 }
            expect(recorder.calls.count).to(equal(1))

            bridge.handleFilterResult(["a"])
            expect(ids(first)).to(equal(["a"]))
            expect(second).to(beNil())
            expect(recorder.calls.count).to(equal(2))
            expect(recorder.calls.last?.ids).to(equal(["b", "c"]))

            bridge.handleFilterResult(["c"])
            expect(ids(second)).to(equal(["c"]))
        }

        it("does not apply a late filter answer to the next request") {
            let bridge = makeBridge(filter: true, sort: false, timeout: 0.05)
            var first: [InAppContentBlockResponse]?
            bridge.select(input) { first = $0 }
            expect(ids(first)).toEventually(equal(["a", "b", "c"]))

            var second: [InAppContentBlockResponse]?
            bridge.select(["a", "b", "c", "d"].map(contentBlock)) { second = $0 }
            expect(recorder.calls.count).to(equal(2))

            // Dart answers the timed-out request, then reports it handled.
            expect(bridge.handleFilterResult(["c", "a"])).to(beFalse())
            recorder.handled(0)
            expect(second).to(beNil())

            expect(bridge.handleFilterResult(["d", "a"])).to(beTrue())
            expect(ids(second)).to(equal(["d", "a"]))
        }

        it("does not apply a late sort answer to the next request") {
            let bridge = makeBridge(filter: false, sort: true, timeout: 0.05)
            var first: [InAppContentBlockResponse]?
            bridge.select(input) { first = $0 }
            expect(ids(first)).toEventually(equal(["a", "b", "c"]))

            var second: [InAppContentBlockResponse]?
            bridge.select(["a", "b", "c", "d"].map(contentBlock)) { second = $0 }
            expect(bridge.handleSortResult(["c", "b", "a"])).to(beFalse())
            recorder.handled(0)
            expect(second).to(beNil())

            expect(bridge.handleSortResult(["d", "c", "b", "a"])).to(beTrue())
            expect(ids(second)).to(equal(["d", "c", "b", "a"]))
            let data = ["a", "b", "c", "d"].map { StaticReturnData(html: "", tag: 0, message: contentBlock($0)) }
            expect(bridge.applyDartSortOrder(to: data)?.map { $0.message?.id }).to(equal(["d", "c", "b", "a"]))
        }

        it("matches the next answer to the next request when a timed-out request got no answer") {
            let bridge = makeBridge(filter: true, sort: false, timeout: 0.05)
            var first: [InAppContentBlockResponse]?
            bridge.select(input) { first = $0 }
            expect(ids(first)).toEventually(equal(["a", "b", "c"]))

            var second: [InAppContentBlockResponse]?
            bridge.select(["b", "c"].map(contentBlock)) { second = $0 }
            // Dart handled the timed-out request without answering it.
            recorder.handled(0)

            expect(bridge.handleFilterResult(["c"])).to(beTrue())
            expect(ids(second)).to(equal(["c"]))
        }

        it("falls back at once when Dart handles a request without answering") {
            let bridge = makeBridge(filter: true, sort: true)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            recorder.handled(0)
            expect(recorder.calls.map { $0.method }).to(equal([filterMethod, sortMethod]))
            expect(result).to(beNil())

            recorder.handled(1)
            expect(ids(result)).to(equal(["a", "b", "c"]))
            expect(bridge.applyDartSortOrder(to: [])).to(beNil())
        }

        it("ignores the reply of a request that was already answered") {
            let bridge = makeBridge(filter: true, sort: false)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            bridge.handleFilterResult(["b"])
            recorder.handled(0)
            expect(ids(result)).to(equal(["b"]))
        }

        it("rejects a result when no request is waiting") {
            let bridge = makeBridge(filter: true, sort: true)
            expect(bridge.handleFilterResult(["a", "b", "c"])).to(beFalse())
            expect(bridge.handleSortResult(["a", "b", "c"])).to(beFalse())
        }

        it("does not call Dart when there are no blocks to filter or sort") {
            let bridge = makeBridge(filter: true, sort: true)
            var result: [InAppContentBlockResponse]?
            bridge.select([]) { result = $0 }
            expect(ids(result)).to(equal([]))
            expect(recorder.calls).to(beEmpty())
        }

        it("does not call the Dart sort when the Dart filter keeps no blocks") {
            let bridge = makeBridge(filter: true, sort: true)
            var result: [InAppContentBlockResponse]?
            bridge.select(input) { result = $0 }
            bridge.handleFilterResult([])
            expect(ids(result)).to(equal([]))
            expect(recorder.calls.map { $0.method }).to(equal([filterMethod]))
        }

        describe("parsing a Dart answer") {
            it("reads the IDs of blocks the native model cannot decode") {
                let answer = [#"{"id": "a"}"#, #"{"id": "b", "name": "Block b", "unexpected": [1]}"#]
                expect(ContentBlockCarouselSelectionBridge.parseAnswerIds(answer)).to(equal(["a", "b"]))
            }

            it("reads the IDs of blocks encoded as the Dart encoder does") {
                let answer = [
                    #"{"id": "a", "name": "Block a", "date_filter": {"enabled": false}, "placeholders": ["example_carousel"], "load_priority": 1}"#
                ]
                expect(ContentBlockCarouselSelectionBridge.parseAnswerIds(answer)).to(equal(["a"]))
            }

            it("skips entries without an ID") {
                let answer: [Any] = [#"{"name": "no id"}"#, "not json", 42, #"{"id": "c"}"#]
                expect(ContentBlockCarouselSelectionBridge.parseAnswerIds(answer)).to(equal(["c"]))
            }

            it("rejects an answer that is not a list") {
                expect(ContentBlockCarouselSelectionBridge.parseAnswerIds(nil)).to(beNil())
                expect(ContentBlockCarouselSelectionBridge.parseAnswerIds(#"{"id": "a"}"#)).to(beNil())
            }
        }
    }
}
