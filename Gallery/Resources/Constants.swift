//
//  Constants.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import UIKit

struct Constants {
    static let screenScale = UIScreen().scale
    static let baseAPIEndpointURL = URL(string: "https://api.unsplash.com")!
    static let photosFetchPageSize = 30
    static let imageFetchThreshold = 30
    /// The maximum number of images that can be stored in the image cache service at one time.
    static let imageCacheServiceCountLimit = 100
    /// The cooldown time (in seconds) between showing the same alert to the user.
    static let alertCooldownTime: TimeInterval = 15
}

extension Constants {
    struct UserInterface {
        static let photoCellMinimalWidth: CGFloat = 100
        static let photoCellHeight: CGFloat = 84
        static let photoCellSpacing: CGFloat = 16
        
        static let smallIconSize: CGFloat = 12
    }
}
