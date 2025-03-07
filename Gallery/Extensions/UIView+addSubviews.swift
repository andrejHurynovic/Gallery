//
//  UIView+addSubviews.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 06.03.2025.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
