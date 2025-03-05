//
//  UIEdgeInsets+initAllSides.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

extension UIEdgeInsets {
    init(allSides: CGFloat) {
        self.init(top: allSides, left: allSides, bottom: allSides, right: allSides)
    }
}
