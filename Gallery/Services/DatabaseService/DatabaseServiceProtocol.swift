//
//  DatabaseServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 08.03.2025.
//

import Foundation

protocol DatabaseServiceProtocol: Actor {
    func insert(post: Photo) -> PersistentPost?
    func update(post: PersistentPost, action: (PersistentPost) -> Void)
    func delete(post: PersistentPost)
    
    func fetchPosts(after date: Date) -> [PersistentPost]?
    func fetchPosts(with ids: Set<String>) -> [PersistentPost]?
    
    func getPostsIds() async -> Set<String>
}
