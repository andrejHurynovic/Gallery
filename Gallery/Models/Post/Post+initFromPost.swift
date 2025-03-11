//
//  Post+initFromPost.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

extension Post {
    convenience init(from post: any PostProtocol) {
        self.init(id: post.id,
                  width: post.width,
                  height: post.height,
                  hexadecimalColorCode: post.hexadecimalColorCode,
                  publicationDate: post.publicationDate,
                  descriptionText: post.descriptionText,
                  alternativeDescriptionText: post.alternativeDescriptionText,
                  views: post.views,
                  likes: post.likes,
                  downloads: post.downloads,
                  imageURL: post.imageURL,
                  downloadURL: post.downloadURL)
    }
}
