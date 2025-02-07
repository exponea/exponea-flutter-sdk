//
//  SegmentationData.swift
//  exponea
//

import Foundation
import ExponeaSDK

struct SegmentationData {
    public let instanceId: String
    public let data: [SegmentDTO]

    func toMap() -> [String: Any] {
        return [
            "instanceId": instanceId,
            "data": data.map { return ["id" : $0.id, "segmentation_id" : $0.segmentationId] }
        ]
    }
}
