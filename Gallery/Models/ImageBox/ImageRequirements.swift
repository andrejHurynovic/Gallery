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
    
    private(set) var width: Int
    private(set) var height: Int
    
    init(from post: any PhotoProtocol, width: CGFloat, height: CGFloat) {
        id = post.id
        imageURL = post.imageURL
        self.width = Int(width * Constants.screenScale)
        self.height = Int(height * Constants.screenScale)
    }
    
    init(from post: any PhotoProtocol, with size: CGSize) {
        self.init(from: post, width: size.width, height: size.height)
    }
}
