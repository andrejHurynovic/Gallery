//
//  Photo.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

final class Photo: PhotoProtocol {
    var id: String
    
    var isFavorite: Bool = false
    
    var width: Int
    var height: Int
    var hexadecimalColor: String
    
    var publishedDate: Date
    var descriptionText: String?
    var alternativeDescriptionText: String?
    
    var views: Int?
    var likes: Int
    var downloads: Int?
    
    var location: Location?
    
    var imageURL: String
    var downloadURL: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        hexadecimalColor = try container.decode(String.self, forKey: .color)
        
        guard let publishedDate = ISO8601DateFormatter().date(from: try container.decode(String.self, forKey: .publishedDate)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.publishedDate], debugDescription: "Cannot decode publishedDate"))
        }
        self.publishedDate = publishedDate
        descriptionText = try? container.decode(String?.self, forKey: .descriptionText)
        alternativeDescriptionText = try container.decode(String?.self, forKey: .alternativeDescriptionText)
        
        views = try? container.decode(Int.self, forKey: .views)
        likes = try container.decode(Int.self, forKey: .likes)
        downloads = try? container.decode(Int.self, forKey: .downloads)
        
        location = try? container.decode(Location.self, forKey: .location)
        
        let urlsContainer = try container.nestedContainer(keyedBy: URLsContainerCodingKeys.self, forKey: .urlsContainer)
        imageURL = try urlsContainer.decode(String.self, forKey: .raw)
        let linksContainer = try container.nestedContainer(keyedBy: LinksContainerCodingKeys.self, forKey: .linksContainer)
        downloadURL = try linksContainer.decode(String.self, forKey: .downloadLocation)
    }
}
