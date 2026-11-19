//
//  ContentBlockCarouselSelectionBridge.swift
//  exponea
//

import ExponeaSDK
import Foundation

/// Runs the Dart `filterContentBlocks` and `sortContentBlocks` callbacks of a carousel without blocking
/// the main thread.
///
/// Dart answers through the main thread, so waiting for the answer there can never succeed: every request
/// would end in a timeout, and the main thread would stall for the whole timeout, delaying every other
/// native view on screen. Instead, each request completes asynchronously when Dart answers or when
/// `responseTimeout` elapses, whichever comes first. A timed-out request falls back to the native result.
///
/// Selections run one at a time, filter first and then sort. A request that timed out can still get a
/// late answer while a newer request of the same kind waits, so answers are matched to requests by order:
/// Dart handles requests one after another, and `Invoke` reports a request handled only after any answer
/// to it has been delivered, so an answer belongs to the oldest request Dart has neither answered nor
/// reported handled. The exception is a request that timed out without an answer: when the main thread
/// stalls past the timeout before that request is reported handled, the answer to the next request of
/// the same kind can arrive first, is taken for the older request, and the newer request falls back to
/// the native result. Every member must be used on the main thread.
final class ContentBlockCarouselSelectionBridge {
    static let methodFilterContentBlocks = "filterContentBlocks"
    static let methodSortContentBlocks = "sortContentBlocks"

    /// Sends a request to Dart. Returns `false` when the request could not be delivered.
    /// `onHandled` must be called on the main thread once Dart has finished handling the request,
    /// whether or not it answered, and only after any answer it sent has been delivered through
    /// `handleFilterResult` or `handleSortResult`.
    typealias Invoke = (
        _ method: String,
        _ contentBlocks: [InAppContentBlockResponse],
        _ onHandled: @escaping () -> Void
    ) -> Bool

    private enum Kind {
        case filter
        case sort

        var method: String {
            switch self {
            case .filter: return ContentBlockCarouselSelectionBridge.methodFilterContentBlocks
            case .sort: return ContentBlockCarouselSelectionBridge.methodSortContentBlocks
            }
        }
    }

    private struct PendingRequest {
        let id: UUID
        /// Called with the IDs Dart answered, or nil when the native result applies.
        let completion: ([String]?) -> Void
    }

    private struct Selection {
        let input: [InAppContentBlockResponse]
        let completion: ([InAppContentBlockResponse]) -> Void
    }

    let filtrationSet: Bool
    let sortingSet: Bool
    private let responseTimeout: TimeInterval
    private let invoke: Invoke

    /// The request of each kind whose selection is waiting for it.
    private var pending: [Kind: PendingRequest] = [:]
    /// IDs of the requests of each kind that Dart has neither answered nor reported handled, oldest first.
    /// Includes requests that already timed out, so their late answers are recognized and ignored.
    private var inFlight: [Kind: [UUID]] = [:]
    private var queuedSelections: [Selection] = []
    private var isSelecting = false
    /// IDs in the order returned by the Dart sort for the latest selection, or nil when the
    /// native sort applies.
    private var dartSortOrder: [String]?

    init(filtrationSet: Bool, sortingSet: Bool, responseTimeout: TimeInterval, invoke: @escaping Invoke) {
        self.filtrationSet = filtrationSet
        self.sortingSet = sortingSet
        self.responseTimeout = responseTimeout
        self.invoke = invoke
    }

    /// Applies the Dart filter and sort to `input` and calls `completion` with the result.
    /// Completes synchronously when neither callback is set.
    func select(
        _ input: [InAppContentBlockResponse],
        completion: @escaping ([InAppContentBlockResponse]) -> Void
    ) {
        dispatchPrecondition(condition: .onQueue(.main))
        queuedSelections.append(Selection(input: input, completion: completion))
        runNextSelection()
    }

    /// Orders `data` as the Dart sort of the latest selection returned it.
    /// Returns nil when the Dart sort is not set or did not answer in time, so the native sort applies.
    func applyDartSortOrder(to data: [StaticReturnData]) -> [StaticReturnData]? {
        guard sortingSet, let dartSortOrder else {
            return nil
        }
        return dartSortOrder.compactMap { id in
            data.first { $0.message?.id == id }
        }
    }

    /// Delivers the IDs of the Dart filter answer. Returns false when it answers a request that already
    /// timed out, or no filter request is waiting.
    @discardableResult
    func handleFilterResult(_ ids: [String]) -> Bool {
        return deliverAnswer(.filter, ids)
    }

    /// Delivers the IDs of the Dart sort answer. Returns false when it answers a request that already
    /// timed out, or no sort request is waiting.
    @discardableResult
    func handleSortResult(_ ids: [String]) -> Bool {
        return deliverAnswer(.sort, ids)
    }

    /// Reads the content block IDs from a Dart answer, a list of content blocks encoded as JSON strings.
    /// Only the IDs are read, because the answer is matched against the blocks of the request by ID;
    /// decoding whole blocks would drop any block the native model cannot decode. Returns nil when the
    /// answer is not a list.
    static func parseAnswerIds(_ arguments: Any?) -> [String]? {
        guard let list = arguments as? [Any] else {
            return nil
        }
        let decoder = JSONDecoder()
        return list
            .compactMap { ($0 as? String)?.data(using: .utf8) }
            .compactMap { try? decoder.decode(AnsweredContentBlock.self, from: $0).id }
    }

    private struct AnsweredContentBlock: Decodable {
        let id: String
    }

    private func runNextSelection() {
        guard !isSelecting, !queuedSelections.isEmpty else {
            return
        }
        isSelecting = true
        let selection = queuedSelections.removeFirst()
        dartSortOrder = nil
        filter(selection.input) { filtered in
            self.sort(filtered) { sorted, sortOrder in
                self.dartSortOrder = sortOrder
                selection.completion(sorted)
                self.isSelecting = false
                self.runNextSelection()
            }
        }
    }

    private func filter(
        _ input: [InAppContentBlockResponse],
        completion: @escaping ([InAppContentBlockResponse]) -> Void
    ) {
        // Nothing to filter: skip the round trip, so an empty carousel is reported without waiting for Dart.
        guard filtrationSet, !input.isEmpty else {
            completion(input)
            return
        }
        request(.filter, input) { answeredIds in
            guard let answeredIds else {
                completion(input)
                return
            }
            completion(Self.retrieveMatchingById(input, answeredIds))
        }
    }

    private func sort(
        _ input: [InAppContentBlockResponse],
        completion: @escaping ([InAppContentBlockResponse], [String]?) -> Void
    ) {
        // Nothing to sort: skip the round trip, so an empty carousel is reported without waiting for Dart.
        guard sortingSet, !input.isEmpty else {
            completion(input, nil)
            return
        }
        request(.sort, input) { answeredIds in
            guard let answeredIds else {
                completion(input, nil)
                return
            }
            let sorted = Self.retrieveMatchingById(input, answeredIds)
            completion(sorted, sorted.map { $0.id })
        }
    }

    private func request(
        _ kind: Kind,
        _ input: [InAppContentBlockResponse],
        completion: @escaping ([String]?) -> Void
    ) {
        let requestId = UUID()
        pending[kind] = PendingRequest(id: requestId, completion: completion)
        inFlight[kind, default: []].append(requestId)
        let delivered = invoke(kind.method, input) { [weak self] in
            self?.requestHandled(kind, requestId)
        }
        guard delivered else {
            inFlight[kind]?.removeAll { $0 == requestId }
            finish(kind, requestId: requestId, with: nil)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + responseTimeout) { [weak self] in
            guard let self else { return }
            if self.finish(kind, requestId: requestId, with: nil) {
                ExponeaSDK.Exponea.logger.log(
                    .warning,
                    message: "InAppCbCarousel: \(kind.method) got no answer within \(Int(self.responseTimeout * 1000)) ms; using the native result."
                )
            }
        }
    }

    /// Matches a Dart answer to the oldest request of `kind` that Dart has not finished handling,
    /// and completes that request if it is still waiting.
    private func deliverAnswer(_ kind: Kind, _ ids: [String]) -> Bool {
        guard let requestId = inFlight[kind]?.first else {
            return false
        }
        inFlight[kind]?.removeFirst()
        return finish(kind, requestId: requestId, with: ids)
    }

    /// Dart finished handling `requestId`. Any answer it sent has already been delivered, so the request
    /// and every older one of `kind` will not be answered anymore. A request still waiting here got no
    /// answer, for example because the Dart callback threw, and falls back to the native result now.
    private func requestHandled(_ kind: Kind, _ requestId: UUID) {
        if let index = inFlight[kind]?.firstIndex(of: requestId) {
            inFlight[kind]?.removeSubrange(...index)
        }
        if finish(kind, requestId: requestId, with: nil) {
            ExponeaSDK.Exponea.logger.log(
                .warning,
                message: "InAppCbCarousel: \(kind.method) returned no result; using the native result."
            )
        }
    }

    /// Completes the waiting request of `kind` if it is still `requestId`. Returns false when nothing
    /// was completed.
    @discardableResult
    private func finish(_ kind: Kind, requestId: UUID, with answeredIds: [String]?) -> Bool {
        guard let pending = self.pending[kind], pending.id == requestId else {
            return false
        }
        self.pending[kind] = nil
        pending.completion(answeredIds)
        return true
    }

    /// Keeps the blocks of `source` whose IDs Dart returned, in the order Dart returned them.
    private static func retrieveMatchingById(
        _ source: [InAppContentBlockResponse],
        _ idsToMatch: [String]
    ) -> [InAppContentBlockResponse] {
        return source
            .filter { idsToMatch.contains($0.id) }
            .sorted {
                idsToMatch.firstIndex(of: $0.id) ?? -1 < idsToMatch.firstIndex(of: $1.id) ?? -1
            }
    }
}
