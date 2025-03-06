//
//  UIStackView+addArrangedSubviews.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 06.03.2025.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        for view in views {
            addArrangedSubview(view)
        }
    }
}
