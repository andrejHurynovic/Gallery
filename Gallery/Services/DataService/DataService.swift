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
    
    @Injected var networkService: (any NetworkServiceProtocol)?
    @Injected var imageCacheService: (any ImageCacheServiceProtocol)?
    
    private var currentFetchPage = 1
    private var lastQuery: String?
    private var photosIDs: Set<String> = []
    
    private var temporaryFavoritePhotosProvided: Int = 0
    private var temporaryFavoritePhotos: [any PhotoProtocol] = []
    
    var photosUpdatePublisher = PassthroughSubject<any PhotoProtocol, Never>()
}

// MARK: - Photos
extension DataService {
    func getPhoto(for id: String) async -> (any PhotoProtocol)? {
        guard let data = await networkService?.fetch(APIEndpoint.photo(id: id)),
              let photo = try? JSONDecoder().decode(Photo.self, from: data) else { return nil }
        return photo
    }
}

// MARK: - Photos
extension DataService {
    func getPhotos(for query: String?) async -> [any PhotoProtocol]? {
        if lastQuery != query {
            lastQuery = query
            currentFetchPage = 1
            photosIDs.removeAll()
        }
        let photos: [Photo]?
        if let query {
            photos = await fetchPhotos(for: query)
        } else {
            photos = await fetchPhotos()
        }
        guard var photos else { return nil }
        photos.removeAll { photosIDs.contains($0.id) }
        photosIDs.formUnion(photos.map { $0.id })
        
        currentFetchPage += 1
        return photos
    }
    
    func getFavoritePhotos() async -> [any PhotoProtocol]? {
        guard temporaryFavoritePhotosProvided < temporaryFavoritePhotos.count else { return nil }
        let bounds = temporaryFavoritePhotosProvided...(temporaryFavoritePhotosProvided+Constants.photosFetchPageSize)
        let photos: [any PhotoProtocol].SubSequence
        if bounds.upperBound > temporaryFavoritePhotos.count {
            photos = (temporaryFavoritePhotos[temporaryFavoritePhotosProvided...])
        } else {
            photos = (temporaryFavoritePhotos[bounds])
        }
        temporaryFavoritePhotosProvided += photos.count
        return Array(photos)
    }
    
    func changePersistenceStatus(for photo: any PhotoProtocol, isFavorite: Bool) async {
        var photo = photo
        photo.isFavorite = isFavorite
        temporaryFavoritePhotos.append(photo)
        photosUpdatePublisher.send(photo)
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
        let requirements = ImageRequirements(id: photo.id,
                                             imageURL: photo.imageURL,
                                             requiredWidth: CGFloat(photo.width),
                                             requiredHeight: CGFloat(photo.height))
        guard let imageBox = await fetchImageBox(for: APIEndpoint.imageWithRequirements(requirements)) else { return nil }
        imageCacheService?.addImage(id: requirements.id, imageBox)
        return imageBox
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
