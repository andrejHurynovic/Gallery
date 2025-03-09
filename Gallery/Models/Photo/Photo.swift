//
//  Photo.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

final class Photo: PhotoProtocol {
    var id: String
    
    var isPersistent: Bool { return false }
    
    var width: Int32
    var height: Int32
    var hexadecimalColorCode: String
    
    var publicationDate: Date
    var descriptionText: String?
    var alternativeDescriptionText: String?
    
    var views: Int32?
    var likes: Int32
    var downloads: Int32?
    
    var imageURL: String
    var downloadURL: String
    
    // MARK: - Initialization
    
    init(id: String,
         width: Int32,
         height: Int32,
         hexadecimalColorCode: String,
         publicationDate: Date,
         descriptionText: String?,
         alternativeDescriptionText: String?,
         views: Int32?,
         likes: Int32,
         downloads: Int32?,
         imageURL: String,
         downloadURL: String) {
        self.id = id
        self.width = width
        self.height = height
        self.hexadecimalColorCode = hexadecimalColorCode
        self.publicationDate = publicationDate
        self.descriptionText = descriptionText
        self.alternativeDescriptionText = alternativeDescriptionText
        self.views = views
        self.likes = likes
        self.downloads = downloads
        self.imageURL = imageURL
        self.downloadURL = downloadURL
    }
    
    // MARK: - Decoder
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        width = try container.decode(Int32.self, forKey: .width)
        height = try container.decode(Int32.self, forKey: .height)
        hexadecimalColorCode = try container.decode(String.self, forKey: .color)
        
        guard let publishedDate = ISO8601DateFormatter().date(from: try container.decode(String.self, forKey: .publicationDate)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.publicationDate], debugDescription: "Cannot decode publicationDate"))
        }
        self.publicationDate = publishedDate
        descriptionText = try? container.decode(String?.self, forKey: .descriptionText)
        alternativeDescriptionText = try container.decode(String?.self, forKey: .alternativeDescriptionText)
        
        views = try? container.decode(Int32.self, forKey: .views)
        likes = try container.decode(Int32.self, forKey: .likes)
        downloads = try? container.decode(Int32.self, forKey: .downloads)
        
        let urlsContainer = try container.nestedContainer(keyedBy: URLsContainerCodingKeys.self, forKey: .urlsContainer)
        imageURL = try urlsContainer.decode(String.self, forKey: .raw)
        let linksContainer = try container.nestedContainer(keyedBy: LinksContainerCodingKeys.self, forKey: .linksContainer)
        downloadURL = try linksContainer.decode(String.self, forKey: .downloadLocation)
    }
}
