//
//  Constants.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import UIKit

struct Constants {
    static let screenScale = UIScreen().scale
    /// The maximum number of images that can be stored in the image cache service at one time.
    static let imageCacheServiceCountLimit = 100
    /// The cooldown time (in seconds) between showing the same alert to the user.
    static let alertCooldownTime: TimeInterval = 15
}
