//
//  ImageCacheService.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

final class ImageCacheService<ImageBoxType: ImageBoxProtocol>: ImageCacheServiceProtocol {
    private let storage: NSCache<NSString, ImageBoxType>
    
    // MARK: - Initialization
    init(countLimit: Int = UserDefaults.standard.value(forKey: Constants.UserDefaults.imageCacheServiceCountLimit) as? Int ?? Constants.imageCacheServiceCountLimit) {
        storage = NSCache<NSString, ImageBoxType>()
        storage.countLimit = countLimit
    }
    
    // MARK: - Public
    func addImage(id: String, _ imageBox: any ImageBoxProtocol) {
        guard let imageBox = imageBox as? ImageBoxType else { return }
        storage.setObject(imageBox, forKey: id as NSString)
    }
    
    func popImage(id: String) -> (any ImageBoxProtocol)? {
        guard let imageBox = storage.object(forKey: id as NSString) else { return nil }
        storage.removeObject(forKey: id as NSString)
        return imageBox
    }
    
    func getImage(_ requirements: any ImageRequirementsProtocol) -> (any ImageBoxProtocol)? {
        guard let imageBox = storage.object(forKey: requirements.id as NSString) else { return nil }
        guard imageBox.meet(requirements: requirements) else {
            return nil
        }
        return imageBox
    }
}
