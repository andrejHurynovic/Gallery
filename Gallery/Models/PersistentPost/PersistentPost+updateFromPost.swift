//
//  PersistentPost+updateFromPost.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 08.03.2025.
//

extension PersistentPost {
    func update(from post: any PostProtocol) {
        id = post.id
        width = post.width
        height = post.height
        hexadecimalColorCode = post.hexadecimalColorCode
        publicationDate = post.publicationDate
        descriptionText = post.descriptionText
        alternativeDescriptionText = post.alternativeDescriptionText
        views = post.views ?? views
        likes = post.likes
        downloads = post.downloads ?? downloads
        imageURL = post.imageURL
        downloadURL = post.downloadURL
    }
}
