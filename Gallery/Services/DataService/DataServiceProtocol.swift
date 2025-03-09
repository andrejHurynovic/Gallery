//
//  DataServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Combine

protocol DataServiceProtocol: Actor {
    var photosUpdatePublisher: PassthroughSubject<any PhotoProtocol, Never> { get }
    
    func updatePhoto(photo: any PhotoProtocol) async
    func changePersistenceStatus(for photo: any PhotoProtocol, isPersistent: Bool) async
    
    func getPhotos(for query: String?) async -> [any PhotoProtocol]?
    func getFavoritePhotos() async -> [any PhotoProtocol]?
    
    func scaledImage(for requirements: ImageRequirementsProtocol) async -> (any ImageBoxProtocol)?
    func rawImage(for photo: any PhotoProtocol) async -> (any ImageBoxProtocol)?
    func downloadImage(for photo: any PhotoProtocol) async -> (any ImageBoxProtocol)?
}
