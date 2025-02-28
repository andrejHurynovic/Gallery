//
//  Photo+Decodable.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

extension Photo: Decodable { }

extension Photo {
    enum CodingKeys: String, CodingKey {
        case id
        
        case width
        case height
        case color
        
        case publishedDate = "created_at"
        case descriptionText = "description"
        case alternativeDescriptionText = "alt_description"
        
        case views
        case likes
        case downloads
        
        case location
        
        case urlsContainer = "urls"
        case linksContainer = "links"
    }
    
    enum URLsContainerCodingKeys: String, CodingKey {
        case raw
    }
    enum LinksContainerCodingKeys: String, CodingKey {
        case downloadLocation = "download_location"
    }
}
