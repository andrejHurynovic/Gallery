//
//  Photo+updateWith.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 07.03.2025.
//

extension Photo {
    func updateWith(photo: any PhotoProtocol) {
        views = photo.views
        likes = photo.likes
        downloads = photo.downloads
    }
}
