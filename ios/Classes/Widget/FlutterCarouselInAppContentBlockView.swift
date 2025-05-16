//
//  FlutterCarouselView.swift
//  exponea
//

import Foundation
import ExponeaSDK

class FlutterCarouselInAppContentBlockView: CarouselInAppContentBlockView {

    private let widget: FlutterInAppContentBlockCarousel

    init(
        placeholder: String,
        maxMessagesCount: Int?,
        scrollDelay: TimeInterval?,
        behaviourCallback: DefaultContentBlockCarouselCallback,
        widget: FlutterInAppContentBlockCarousel
    ) {
        self.widget = widget
        if let maxMessagesCount, let scrollDelay {
            super.init(
                placeholder: placeholder,
                maxMessagesCount: maxMessagesCount,
                scrollDelay: scrollDelay,
                behaviourCallback: behaviourCallback
            )
        } else if let maxMessagesCount {
            super.init(
                placeholder: placeholder,
                maxMessagesCount: maxMessagesCount,
                behaviourCallback: behaviourCallback
            )
        } else if let scrollDelay {
            super.init(
                placeholder: placeholder,
                scrollDelay: scrollDelay,
                behaviourCallback: behaviourCallback
            )
        } else {
            super.init(
                placeholder: placeholder,
                behaviourCallback: behaviourCallback
            )
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func filterContentBlocks(
        placeholder: String,
        continueCallback: TypeBlock<[InAppContentBlockResponse]>?,
        expiredCompletion: EmptyBlock?
    ) {
        guard let continueCallback else {
            return
        }
        super.filterContentBlocks(
            placeholder: placeholder,
            continueCallback: { [weak self] loadedContentBlocks in
                guard let self else {
                    continueCallback(loadedContentBlocks)
                    return
                }
                let filteredContentBlocks = widget.filterContentBlocks(loadedContentBlocks)
                continueCallback(filteredContentBlocks)
            },
            expiredCompletion: expiredCompletion
        )
    }
    override func sortContentBlocks(data: [StaticReturnData]) -> [StaticReturnData] {
        let contentBlocksToSort = data.compactMap { $0.message }
        let sortedContentBlocks = widget.sortContentBlocks(contentBlocksToSort)
        let sortedStaticData = sortedContentBlocks.compactMap { sortedContentBlock in
            data.first { $0.message?.id == sortedContentBlock.id }
        }
        return sortedStaticData
    }
}
