//
//  DataService.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Foundation

final class DataService: DataServiceProtocol {
    typealias ImageBoxType = ImageBox
    
    @Injected var networkService: (any NetworkServiceProtocol)?
    @Injected var imageCacheService: (any ImageCacheServiceProtocol)?
    
    private var lastQuery: String?
    private var photosIDs: Set<String> = []
    
    private var currentFetchPage = 0
    
    // MARK: - Public
    func getPhoto(for id: String) async -> (any PhotoProtocol)? {
        guard let data = await networkService?.fetch(APIEndpoint.photo(id: id)),
              let photo = try? JSONDecoder().decode(Photo.self, from: data) else { return nil }
        return photo
    }
    
    func getPhotos(for query: String?) async -> [any PhotoProtocol]? {
        if lastQuery != query {
            lastQuery = query
            currentFetchPage = 0
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
    
    func scaledImage(for requirements: any ImageRequirementsProtocol) async -> (any ImageBoxProtocol)? {
        if let imageBox = imageCacheService?.getImage(requirements) { return imageBox }
        
        guard let data = await networkService?.fetch(APIEndpoint.imageWithRequirements(requirements)),
              let imageBox = ImageBoxType(from: data) else { return nil }
        imageCacheService?.addImage(id: requirements.id, imageBox)
        return imageBox
    }
    
    func rawImage(for photo: Photo) async -> (any ImageBoxProtocol)? {
        return nil
    }
    
    func downloadImage(for photo: any PhotoProtocol) async -> (any ImageBoxProtocol)? {
        return nil
    }
    
    // MARK: - Private
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
