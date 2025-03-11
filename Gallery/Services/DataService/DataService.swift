//
//  DataService.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Foundation
import Combine

final actor DataService: DataServiceProtocol {
    typealias ImageBoxType = ImageBox
    
    @Injected private var networkService: (any NetworkServiceProtocol)?
    @Injected private var databaseService: (any DatabaseServiceProtocol)?
    @Injected private var imageCacheService: (any ImageCacheServiceProtocol)?
    
    private var currentFetchPage = 1
    private var lastQuery: String?
    
    private var postsIds: Set<String> = []
    private var persistentPostsIds: Set<String>?
    
    private lazy var lastFetchedFavoritePostDateOfInsertion: Date = Date()
    
    var postsUpdatePublisher = PassthroughSubject<any PostProtocol, Never>()
}

// MARK: - Posts
extension DataService {
    func updatePost(post: any PostProtocol) async {
        guard let data = await networkService?.fetch(APIEndpoint.post(id: post.id)),
              let updatedPost = try? JSONDecoder().decode(Post.self, from: data) else { return }
        if post.isPersistent,
           let persistentPost = post as? PersistentPost {
            await databaseService?.update(post: persistentPost, action: { $0.update(from: updatedPost) })
        } else {
            post.update(from: updatedPost)
        }
    }
    
    func changePersistenceStatus(for post: any PostProtocol, to isPersistent: Bool) async {
        if isPersistent {
            guard let post = post as? Post,
                  let persistentPost = await databaseService?.insert(post: post) else { return }
            postsUpdatePublisher.send(persistentPost)
        } else {
            guard let persistentPost = post as? PersistentPost else { return }
            let post = Post(from: persistentPost)
            await databaseService?.delete(post: persistentPost)
            postsUpdatePublisher.send(post)
        }
    }
}

// MARK: - Posts
extension DataService {
    func getPosts(for query: String?) async -> [any PostProtocol]? {
        if lastQuery != query {
            lastQuery = query
            currentFetchPage = 1
            postsIds.removeAll()
        }
        let posts: [any PostProtocol]?
        if let query {
            posts = await fetchPosts(for: query)
        } else {
            posts = await fetchPosts()
        }
        guard var posts else { return nil }
        posts.removeAll { postsIds.contains($0.id) }
        postsIds.formUnion(posts.map { $0.id })
        
        await replaceToPersistencePosts(posts: &posts)
        
        currentFetchPage += 1
        return posts
    }
    
    private func replaceToPersistencePosts(posts: inout [any PostProtocol]) async {
        if persistentPostsIds == nil {
            persistentPostsIds = await databaseService?.getPostsIds()
        }
        var postsDictionary: [String: any PostProtocol] = Dictionary(uniqueKeysWithValues: posts.map({ ($0.id, $0) }))
        let persistentPostsIds = persistentPostsIds!.intersection(postsDictionary.keys)
        guard let persistentPosts = await databaseService?.fetchPosts(with: persistentPostsIds) else { return }
        
        for persistentPost in persistentPosts {
            postsDictionary[persistentPost.id] = persistentPost
        }
        posts = Array(postsDictionary.values)
    }
    
    func getFavoritePosts() async -> [any PostProtocol]? {
        guard let posts = await databaseService?.fetchPosts(after: lastFetchedFavoritePostDateOfInsertion),
              let lastFavoritePoseDateOfInsertion = posts.last?.dateOfInsertion else { return nil }
        self.lastFetchedFavoritePostDateOfInsertion = lastFavoritePoseDateOfInsertion
        return Array(posts)
    }
    
    private func fetchPosts() async -> [Post]? {
        guard let data = await networkService?.fetch(APIEndpoint.posts(page: currentFetchPage, postsPerPage: Constants.postsFetchPageSize)) else { return nil }
        return try? JSONDecoder().decode([Post].self, from: data)
    }
    
    private func fetchPosts(for query: String) async -> [Post]? {
        guard let data = await networkService?.fetch(APIEndpoint.postsSearch(page: currentFetchPage, postsPerPage: Constants.postsFetchPageSize, query: query)),
              let result = try? JSONDecoder().decode(PostsSearchResult.self, from: data) else { return nil }
        return result.results
    }
}

// MARK: - Images
extension DataService {
    func scaledImage(for post: any PostProtocol, with size: CGSize) async -> (any ImageBoxProtocol)? {
        let requirements = ImageRequirements(from: post, with: size)
        let imageBox = await fetchImage(for: post, with: requirements)
        
        return imageBox
    }
    
    private func fetchImage(for post: any PostProtocol, with requirements: any ImageRequirementsProtocol) async -> (any ImageBoxProtocol)? {
        if post.isPersistent,
           let persistentPost = post as? PersistentPost,
           let persistentImageBox = persistentPost.imageBox,
           persistentImageBox.meet(requirements: requirements) {
            return persistentImageBox
        }
        if let cachedImageBox = imageCacheService?.getImage(requirements) {
            return cachedImageBox
        }
        
        guard let downloadedImageBox = await fetchImageBox(for: APIEndpoint.imageWithRequirements(requirements)) else { return nil }
        if post.isPersistent,
           let persistentPost = post as? PersistentPost {
            Task {
                await databaseService?.update(post: persistentPost, action: {
                    $0.imageBox = downloadedImageBox
                })
            }
        } else {
            imageCacheService?.addImage(id: requirements.id, downloadedImageBox)
        }
        return downloadedImageBox
    }
    
    func rawImage(for post: any PostProtocol) async -> (any ImageBoxProtocol)? {
        let requirements = ImageRequirements(from: post,
                                             width: CGFloat(post.width),
                                             height: CGFloat(post.height))
        return await fetchImage(for: post, with: requirements)
    }
    
    func downloadImage(for post: any PostProtocol) async -> (any ImageBoxProtocol)? {
        guard let urlData = await networkService?.fetch(APIEndpoint.imageDownload(url: post.downloadURL)),
              let urlContainer = try? JSONDecoder().decode(PostDownloadURL.self, from: urlData),
              let data = await networkService?.fetch(APIEndpoint.imageDownload(url: urlContainer.url)) else { return nil }
        return ImageBox(from: data)
    }
    
    private func fetchImageBox(for endpoint: any APIEndpointProtocol) async -> (any ImageBoxProtocol)? {
        guard let data = await networkService?.fetch(endpoint),
              let imageBox = ImageBoxType(from: data) else { return nil }
        return imageBox
    }
}
