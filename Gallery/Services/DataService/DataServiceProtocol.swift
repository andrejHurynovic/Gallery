//
//  DataServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Combine
import CoreGraphics

protocol DataServiceProtocol: Actor {
    var postsUpdatePublisher: PassthroughSubject<any PostProtocol, Never> { get }
    
    func updatePost(post: any PostProtocol) async
    // Adding "to" to the swiftlint exclude list for identifier_name does not work
    // swiftlint:disable identifier_name
    func changePersistenceStatus(for post: any PostProtocol, to: Bool) async
    // swiftlint:enable identifier_name
    func getPosts(for query: String?) async -> [any PostProtocol]?
    func getFavoritePosts() async -> [any PostProtocol]?
    
    func scaledImage(for post: any PostProtocol, with size: CGSize) async -> (any ImageBoxProtocol)?
    func rawImage(for post: any PostProtocol) async -> (any ImageBoxProtocol)?
    func downloadImage(for post: any PostProtocol) async -> (any ImageBoxProtocol)?
}
