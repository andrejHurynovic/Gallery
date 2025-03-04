//
//  ImageCacheService.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

final class ImageCacheService<ImageBoxType: ImageBoxProtocol>: ImageCacheServiceProtocol {
    private let storage: NSCache<NSString, ImageBoxType>
    
    init(countLimit: Int = Constants.imageCacheServiceCountLimit) {
        storage = NSCache<NSString, ImageBoxType>()
        storage.countLimit = countLimit
    }
    
    func addImage(id: String, _ imageBox: any ImageBoxProtocol) {
        guard let imageBox = imageBox as? ImageBoxType else { return }
        storage.setObject(imageBox, forKey: id as NSString)
    }
    
    func getImage(_ requirements: any ImageRequirementsProtocol) -> (any ImageBoxProtocol)? {
        guard let imageBox = storage.object(forKey: requirements.id as NSString) else { return nil }
        guard imageBox.meet(requirements: requirements) else {
            return nil
        }
        return imageBox
    }
}
