//
//  DataServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

protocol DataServiceProtocol {
    func getPhoto(for id: String) async -> (any PhotoProtocol)?
    func getPhotos(for query: String?) async -> [any PhotoProtocol]?
    
    func scaledImage(for requirements: ImageRequirementsProtocol) async -> (any ImageBoxProtocol)?
    func rawImage(for photo: any PhotoProtocol) async -> (any ImageBoxProtocol)?
    func downloadImage(for photo: any PhotoProtocol) async -> (any ImageBoxProtocol)?
}
