//
//  DataServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Combine
import CoreGraphics

protocol DataServiceProtocol: Actor {
    var photosUpdatePublisher: PassthroughSubject<any PhotoProtocol, Never> { get }
    
    func updatePhoto(photo: any PhotoProtocol) async
    // Adding "to" to the swiftlint exclude list for identifier_name does not work
    // swiftlint:disable identifier_name
    func changePersistenceStatus(for photo: any PhotoProtocol, to: Bool) async
    // swiftlint:enable identifier_name
    func getPhotos(for query: String?) async -> [any PhotoProtocol]?
    func getFavoritePhotos() async -> [any PhotoProtocol]?
    
    func scaledImage(for photo: any PhotoProtocol, with size: CGSize) async -> (any ImageBoxProtocol)?
    func rawImage(for photo: any PhotoProtocol) async -> (any ImageBoxProtocol)?
    func downloadImage(for photo: any PhotoProtocol) async -> (any ImageBoxProtocol)?
}
