//
//  ImageBox.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import UIKit

final class ImageBox: ImageBoxProtocol {
    init?(from data: Data) {
        guard let image = UIImage(data: data) else { return nil }
        self.image = image
        width = Int(image.size.width)
        height = Int(image.size.height)
    }
    
    private(set) var width: Int
    private(set) var height: Int
    
    private(set) var image: UIImage
    
    func meet(requirements: any ImageRequirementsProtocol) -> Bool {
        return width >= requirements.requiredWidth && height >= requirements.requiredHeight
    }
}
