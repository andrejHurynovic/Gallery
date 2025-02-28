//
//  ImageRequirements.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import CoreGraphics

struct ImageRequirements: ImageRequirementsProtocol {
    private(set) var id: String
    private(set) var imageURL: String
    
    private(set) var requiredWidth: Int
    private(set) var requiredHeight: Int
    
    init(id: String, imageURL: String, requiredWidth: CGFloat, requiredHeight: CGFloat) {
        self.id = id
        self.imageURL = imageURL
        
        self.requiredWidth = Int(requiredWidth * Constants.screenScale)
        self.requiredHeight = Int(requiredHeight * Constants.screenScale)
    }
}
