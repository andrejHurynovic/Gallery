//
//  NSManagedObjectContext+performWithAlert.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 10.03.2025.
//

import CoreData

extension NSManagedObjectContext {
    func performWithAlert<T>(action: (NSManagedObjectContext) throws -> T?) -> T? {
        do {
            return try action(self)
        } catch {
            @Injected var alertService: (any AlertServiceProtocol)?
            Task { await alertService?.showAlert(for: error) }
        }
        return nil
    }
}
