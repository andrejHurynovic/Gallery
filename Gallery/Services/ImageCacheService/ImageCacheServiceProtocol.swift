//
//  ImageCacheServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

protocol ImageCacheServiceProtocol {
    associatedtype ImageBoxType: ImageBoxProtocol
    
    func addImage(id: String, _ image: ImageBoxType)
    func getImage(_ requirements: ImageRequirementsProtocol) -> ImageBoxType?
}
