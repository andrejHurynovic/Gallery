//
//  KeyPath+string.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 08.03.2025.
//

import Foundation

extension KeyPath where Root: NSObject {
    var string: String {
        NSExpression(forKeyPath: self).keyPath
    }
}
