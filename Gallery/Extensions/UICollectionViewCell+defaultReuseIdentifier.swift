//
//  UICollectionViewCell+defaultReuseIdentifier.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 04.03.2025.
//

import UIKit

extension UICollectionViewCell {
    static var defaultReuseIdentifier: String { return String(describing: self) }
}
