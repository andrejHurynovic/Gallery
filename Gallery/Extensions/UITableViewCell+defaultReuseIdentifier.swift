//
//  UITableViewCell+defaultReuseIdentifier.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

import UIKit

extension UITableViewCell {
    static var defaultReuseIdentifier: String { return String(describing: self) }
}
