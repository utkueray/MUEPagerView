//
//  MUMenuItem.swift
//
//
//  Created by Mehmet Utku Eray on 21.03.2024.
//

import UIKit

public struct MUMenuItem {
    public var title: String?
    public var icon: UIImage?
    public var iconSize: CGSize?
    public var spacing: CGFloat?
    
    public init(title: String?, icon: UIImage? = nil, iconSize: CGSize? = nil, spacing: CGFloat? = nil) {
        self.title = title
        self.icon = icon
        self.iconSize = iconSize
        self.spacing = spacing
    }
    
    public func hasIcon() -> Bool {
        return icon != nil
    }
}
