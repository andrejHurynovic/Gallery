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
    static let postsFetchPageSize = 30
    static let imageFetchThreshold = 30
    /// The maximum number of images that can be stored in the image cache service at one time.
    static let imageCacheServiceCountLimit = 100
    /// The cooldown time (in seconds) between showing the same alert to the user.
    static let alertCooldownTime: TimeInterval = 15
    
    static let animationDuration: TimeInterval = 0.3
}

extension Constants {
    struct UserInterface {
        static let cornerRadius: CGFloat = 10
        static let verticalSpacing: CGFloat = 12
        static let horizontalSpacing: CGFloat = 16
        
        static let postCellMinimalWidth: CGFloat = 100
        static let postCellHeight: CGFloat = 84
        
        static let smallIconSize: CGFloat = 12
        static let largeIconSize: CGFloat = 24
        
        static let mediumButtonSize: CGFloat = largeIconSize * 2
        static let largeButtonSize: CGFloat = largeIconSize * 3
        
        static let iconColor = UIColor.secondaryLabel
        static let borderColor = UIColor.quaternaryLabel
    }
}

extension Constants {
    struct UserDefaults {
        static let imageCacheServiceCountLimit: String = "imageCacheServiceCountLimit"
    }
}
