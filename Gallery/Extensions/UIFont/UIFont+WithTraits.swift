//
//  UIFont+withTraits.swift
//  UIKitLearning
//
//  Created by Andrej Hurynovič on 01.02.2025.
//

import UIKit

extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
