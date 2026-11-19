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
                // The native SDK may call this off the main thread; the Dart round trip needs the main thread.
                onMain {
                    self.widget.selectContentBlocks(loadedContentBlocks, completion: continueCallback)
                }
            },
            expiredCompletion: expiredCompletion
        )
    }
    override func sortContentBlocks(data: [StaticReturnData]) -> [StaticReturnData] {
        // The Dart sort already ran in `filterContentBlocks`; reuse its order instead of asking Dart again.
        return widget.sortContentBlocks(data) ?? super.sortContentBlocks(data: data)
    }
}
