//
//  PersistentPost+initFromPost.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

import CoreData

extension PersistentPost {
    convenience init(from post: Post, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.dateOfInsertion = Date()
        update(from: post)
    }
}
