//
//  NSManagedObjectContext+fetch.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 10.03.2025.
//

import CoreData

extension NSManagedObjectContext {
    func fetch<T>(with request: NSFetchRequest<T>) -> [T]? {
        let result = self.performWithAlert {
            try $0.fetch(request)
        }
        guard result?.isEmpty == false else { return nil }
        return result
    }
}
