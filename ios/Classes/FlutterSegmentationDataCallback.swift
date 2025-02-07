//
//  FlutterSegmentationDataCallback.swift
//  exponea
//

import Foundation
import ExponeaSDK

class FlutterSegmentationDataCallback {
    let instanceId = UUID().uuidString

    let exposingCategory: SegmentCategory
    let includeFirstLoad: Bool
    let onNewData: (FlutterSegmentationDataCallback, [SegmentDTO]) -> Void

    lazy var nativeCallback: SegmentCallbackData = {
        return .init(category: exposingCategory, isIncludeFirstLoad: includeFirstLoad) { data in
            Exponea.logger.log(
                .verbose,
                message: "Segments: New segments for '\(self.exposingCategory)' received: \(data)"
            )
            self.onNewData(self, data)
        }
    }()

    init(
        category: SegmentCategory,
        includeFirstLoad: Bool,
        onNewData: @escaping (FlutterSegmentationDataCallback, [SegmentDTO]) -> Void
    ) {
        self.exposingCategory = category
        self.includeFirstLoad = includeFirstLoad
        self.onNewData = onNewData
    }
}
