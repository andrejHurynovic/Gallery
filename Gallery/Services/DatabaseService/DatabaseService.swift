//
//  DatabaseService.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 08.03.2025.
//

import CoreData

final actor DatabaseService: DatabaseServiceProtocol {
    @Injected private var alertService: (any AlertServiceProtocol)?
    
    private var persistentContainer: NSPersistentContainer
    private lazy var mainContext: NSManagedObjectContext = persistentContainer.viewContext
    private var backgroundContext: NSManagedObjectContext { persistentContainer.newBackgroundContext() }
    
    private var postsIdsToObjectsIds: [String: NSManagedObjectID] = [:]
    
    // MARK: - Initialization
    init() {
        persistentContainer = NSPersistentContainer(name: "Gallery")
        persistentContainer.loadPersistentStores { _, error in
            guard let error else { return }
            Task { [weak self] in
                await self?.alertService?.showAlert(for: error)
            }
        }
    }
    
    private func fetchPostIdsToObjectIds() {
        let results = backgroundContext.performWithAlert {
            return try $0.fetch(idsFetchRequest())
        }
        
        guard let results = results as? [[String: Any]],
              results.isEmpty == false else { return }
        
        let idKey = (\PersistentPost.id).string
        let objectIDKey = (\PersistentPost.objectID).string
        postsIdsToObjectsIds.reserveCapacity(results.count)
        
        for result in results {
            if let postId = result[idKey] as? String,
               let objectID = result[objectIDKey] as? NSManagedObjectID {
                postsIdsToObjectsIds[postId] = objectID
            }
        }
    }
}

// MARK: - Fetch
extension DatabaseService {
    func insert(post: Photo) -> PersistentPost? {
        let context = backgroundContext
        do {
            let post = PersistentPost(from: post, in: context)
            try context.save()
            return try mainContext.existingObject(with: post.objectID) as? PersistentPost
        } catch {
            Task { [weak self] in
                await self?.alertService?.showAlert(for: error)
            }
            
        }
        return nil
    }
    
    func delete(post: PersistentPost) {
        let context = backgroundContext
        postsIdsToObjectsIds.removeValue(forKey: post.id)
        do {
            guard let post = try context.existingObject(with: post.objectID) as? PersistentPost else { return }
            context.delete(post)
            try context.save()
        } catch {
            Task { [weak self] in
                await self?.alertService?.showAlert(for: error)
            }
        }
    }
    
    func update(post: PersistentPost, action: (PersistentPost) -> Void) {
        let context = backgroundContext
        do {
            guard let post = try context.existingObject(with: post.objectID) as? PersistentPost else { return }
            action(post)
            try context.save()
        } catch {
            Task { [weak self] in
                await self?.alertService?.showAlert(for: error)
            }
        }
    }
}

// MARK: - Fetch
extension DatabaseService {
    func fetchPosts(after date: Date) -> [PersistentPost]? {
        var posts: [PersistentPost] = []
        do {
            posts = try mainContext.fetch(fetchRequest(after: date))
        } catch {
            Task { [weak self] in
                await self?.alertService?.showAlert(for: error)
            }
        }
        guard !posts.isEmpty else { return nil }
        return posts
    }
    
    func fetchPosts(with ids: Set<String>) -> [PersistentPost]? {
        let ids = Set(ids.compactMap({ postsIdsToObjectsIds[$0] }))
        return mainContext.fetch(with: fetchRequest(for: ids))
    }
    
    func getPostsIds() async -> Set<String> {
        fetchPostIdsToObjectIds()
        return Set(postsIdsToObjectsIds.keys)
    }
}

// MARK: - Fetch requests
private extension DatabaseService {
    func fetchRequest(after date: Date, fetchLimit: Int = Constants.photosFetchPageSize) -> NSFetchRequest<PersistentPost> {
        let request = PersistentPost.fetchRequest()
        request.predicate = NSPredicate(format: "%K < %@", #keyPath(PersistentPost.dateOfInsertion), date as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PersistentPost.dateOfInsertion, ascending: false)]
        request.fetchLimit = fetchLimit
        return request
    }
    func fetchRequest(for ids: Set<NSManagedObjectID>) -> NSFetchRequest<PersistentPost> {
        let request = PersistentPost.fetchRequest()
        request.predicate = NSPredicate(format: "self in %@", ids)
        return request
    }
    func idsFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: PersistentPost.self))
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [(\PersistentPost.id).string, (\PersistentPost.objectID).string]
        return request
    }
}
extension NSManagedObjectContext {
    func fetch<T>(with request: NSFetchRequest<T>) -> [T]? {
        let result = self.performWithAlert {
            try $0.fetch(request)
        }
        guard result?.isEmpty == false else { return nil }
        return result
    }
}

extension NSManagedObjectContext {
    func performWithAlert<T>(action: (NSManagedObjectContext) throws -> T) -> T? {
        do {
            return try action(self)
        } catch {
            @Injected var alertService: (any AlertServiceProtocol)?
            Task { await alertService?.showAlert(for: error) }
        }
        return nil
    }
}
