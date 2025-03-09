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
    
    private var photosIds: Set<String> = []
    private var persistentPostsIds: Set<String>?
    
    private var lastFetchedFavoritePostDateOfInsertion: Date = Date()
    
    var photosUpdatePublisher = PassthroughSubject<any PhotoProtocol, Never>()
}

// MARK: - Photos
extension DataService {
    func updatePhoto(photo: any PhotoProtocol) async {
        guard let data = await networkService?.fetch(APIEndpoint.photo(id: photo.id)),
              let updatedPhoto = try? JSONDecoder().decode(Photo.self, from: data) else { return }
        if photo.isPersistent,
           let persistentPhoto = photo as? PersistentPost {
            await databaseService?.update(post: persistentPhoto, action: { $0.update(from: updatedPhoto) })
        } else {
            photo.update(from: updatedPhoto)
        }
    }
    
    func changePersistenceStatus(for post: any PhotoProtocol, isPersistent: Bool) async {
        if isPersistent {
            guard let post = post as? Photo,
                  let persistentPost = await databaseService?.insert(post: post) else { return }
            photosUpdatePublisher.send(persistentPost)
        } else {
            guard let persistentPost = post as? PersistentPost else { return }
            let post = Photo(from: persistentPost)
            await databaseService?.delete(post: persistentPost)
            photosUpdatePublisher.send(post)
        }
    }
}

// MARK: - Photos
extension DataService {
    func getPhotos(for query: String?) async -> [any PhotoProtocol]? {
        if lastQuery != query {
            lastQuery = query
            currentFetchPage = 1
            photosIds.removeAll()
        }
        let photos: [any PhotoProtocol]?
        if let query {
            photos = await fetchPhotos(for: query)
        } else {
            photos = await fetchPhotos()
        }
        guard var photos else { return nil }
        photos.removeAll { photosIds.contains($0.id) }
        photosIds.formUnion(photos.map { $0.id })
        
        await replaceToPersistencePosts(posts: &photos)
        
        currentFetchPage += 1
        return photos
    }
    
    private func replaceToPersistencePosts(posts: inout [any PhotoProtocol]) async {
        if persistentPostsIds == nil {
            persistentPostsIds = await databaseService?.getPostsIds()
        }
        var postsDictionary: [String: any PhotoProtocol] = Dictionary(uniqueKeysWithValues: posts.map({ ($0.id, $0) }))
        let persistentPostsIds = persistentPostsIds!.intersection(postsDictionary.keys)
        guard let persistentPosts = await databaseService?.fetchPosts(with: persistentPostsIds) else { return }
        
        for persistentPost in persistentPosts {
            postsDictionary[persistentPost.id] = persistentPost
        }
        posts = Array(postsDictionary.values)
    }
    
    func getFavoritePhotos() async -> [any PhotoProtocol]? {
        guard let posts = await databaseService?.fetchPosts(after: lastFetchedFavoritePostDateOfInsertion),
              let lastFavoritePoseDateOfInsertion = posts.last?.dateOfInsertion else { return nil }
        self.lastFetchedFavoritePostDateOfInsertion = lastFavoritePoseDateOfInsertion
        return Array(posts)
    }
    
    private func fetchPhotos() async -> [Photo]? {
        guard let data = await networkService?.fetch(APIEndpoint.photos(page: currentFetchPage, photosPerPage: Constants.photosFetchPageSize)) else { return nil }
        return try? JSONDecoder().decode([Photo].self, from: data)
    }
    
    private func fetchPhotos(for query: String) async -> [Photo]? {
        guard let data = await networkService?.fetch(APIEndpoint.photosSearch(page: currentFetchPage, photosPerPage: Constants.photosFetchPageSize, query: query)),
              let result = try? JSONDecoder().decode(PhotosSearchResult.self, from: data) else { return nil }
        return result.results
    }
}

// MARK: - Images
extension DataService {
    func scaledImage(for requirements: any ImageRequirementsProtocol) async -> (any ImageBoxProtocol)? {
        if let imageBox = imageCacheService?.getImage(requirements) { return imageBox }
        
        guard let imageBox = await fetchImageBox(for: APIEndpoint.imageWithRequirements(requirements)) else { return nil }
        imageCacheService?.addImage(id: requirements.id, imageBox)
        return imageBox
    }
    
    func rawImage(for photo: any PhotoProtocol) async -> (any ImageBoxProtocol)? {
        guard let imageBox = await fetchImageBox(for: APIEndpoint.imageWithRequirements(requirements)) else { return nil }
        imageCacheService?.addImage(id: requirements.id, imageBox)
        return imageBox
        let requirements = ImageRequirements(from: photo,
                                             width: CGFloat(photo.width),
                                             height: CGFloat(photo.height))
        return await fetchImage(for: photo, with: requirements)
    }
    
    func downloadImage(for photo: any PhotoProtocol) async -> (any ImageBoxProtocol)? {
        guard let urlData = await networkService?.fetch(APIEndpoint.imageDownload(url: photo.downloadURL)),
              let urlContainer = try? JSONDecoder().decode(PhotoDownloadURL.self, from: urlData),
              let data = await networkService?.fetch(APIEndpoint.imageDownload(url: urlContainer.url)) else { return nil }
        return ImageBox(from: data)
    }
    
    private func fetchImageBox(for endpoint: any APIEndpointProtocol) async -> (any ImageBoxProtocol)? {
        guard let data = await networkService?.fetch(endpoint),
              let imageBox = ImageBoxType(from: data) else { return nil }
        return imageBox
    }
}
