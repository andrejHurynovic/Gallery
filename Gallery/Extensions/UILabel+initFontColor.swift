//
//  UILabel+initFontColor.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

extension UILabel {
    convenience init(font: UIFont, color: UIColor? = nil) {
        self.init()
        self.font = font
        if let color { self.textColor = color }
        
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
    }
}
