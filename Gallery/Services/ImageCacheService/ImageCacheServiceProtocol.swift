//
//  ImageCacheServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

protocol ImageCacheServiceProtocol: AnyObject {
    var countLimit: Int { get set }
    
    func addImage(id: String, _ image: any ImageBoxProtocol)
    func popImage(id: String) -> (any ImageBoxProtocol)?
    func getImage(_ requirements: ImageRequirementsProtocol) -> (any ImageBoxProtocol)?
}
