//
//  String+Extensions.swift
//  
//
//  Created by Mehmet Utku Eray on 16.01.2024.
//

import UIKit

extension String {
    func width(font: UIFont, height: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = self
        label.font = font
        return label.widthForLabel(height: height)
    }
}

