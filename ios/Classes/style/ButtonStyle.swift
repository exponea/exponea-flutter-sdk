//
//  ButtonStyle.swift
//  exponea
//
//  Created by Adam Mihalik on 02/03/2023.
//

import Foundation
import UIKit

class ButtonStyle {
    var textOverride: String?
    var textColor: String?
    var backgroundColor: String?
    var showIcon: String?
    var textSize: String?
    var enabled: Bool?
    var borderRadius: String?
    var textWeight: String?

    init(
        textOverride: String? = nil,
        textColor: String? = nil,
        backgroundColor: String? = nil,
        showIcon: String? = nil,
        textSize: String? = nil,
        enabled: Bool? = nil,
        borderRadius: String? = nil,
        textWeight: String? = nil
    ) {
        self.textOverride = textOverride
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.showIcon = showIcon
        self.textSize = textSize
        self.enabled = enabled
        self.borderRadius = borderRadius
        self.textWeight = textWeight
    }

    func applyTo(_ target: UIButton) {
        if let showIcon = showIcon {
            target.setImage(
                UIImage.parse(showIcon)?.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
            target.imageView?.contentMode = .scaleAspectFit
            target.imageEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        }
        if let textOverride = textOverride {
            target.setTitle(textOverride, for: .normal)
        }
        if let textColor = UIColor.parse(textColor) {
            target.setTitleColor(textColor, for: .normal)
            target.tintColor = textColor
        }
        if let backgroundColor = UIColor.parse(backgroundColor) {
            target.backgroundColor = backgroundColor
        }
        if let textSize = CGFloat.parse(textSize),
           let titleLabel = target.titleLabel {
            titleLabel.font = titleLabel.font.withSize(textSize)
        }
        if let textWeight = UIFont.Weight.parse(textWeight),
           let titleLabel = target.titleLabel {
            titleLabel.font = UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: textWeight)
        }
        if let enabled = enabled {
            target.isEnabled = enabled
        }
        if let borderRadius = CGFloat.parse(borderRadius) {
            target.layer.cornerRadius = borderRadius
        }
    }
}
