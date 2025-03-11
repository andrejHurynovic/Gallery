//
//  PersistentPost+fetchRequest.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 08.03.2025.
//

import CoreData

extension PersistentPost: PostProtocol {
    @nonobjc class func fetchRequest() -> NSFetchRequest<PersistentPost> {
        NSFetchRequest<PersistentPost>(entityName: String(describing: PersistentPost.self))
    }
}
