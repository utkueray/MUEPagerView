//
//  UILabel+Extensions.swift
//
//
//  Created by Mehmet Utku Eray on 12.01.2024.
//

import UIKit

extension UILabel {
    func widthForLabel(height: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = self.text
        label.font = self.font
        label.numberOfLines = 0 // or 1 if you want single line

        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = label.text!.boundingRect(with: constraintRect,
                                                   options: .usesLineFragmentOrigin,
                                                   attributes: [.font: label.font!],
                                                   context: nil)

        return ceil(boundingBox.width)
    }
}
