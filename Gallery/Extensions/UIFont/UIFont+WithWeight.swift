//
//  UIFont+WithWeight.swift
//  UIKitLearning
//
//  Created by Andrej Hurynovič on 02.02.2025.
//

import UIKit

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: newDescriptor, size: 0)
    }
}
