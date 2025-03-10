//
//  PhotosListViewModel.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import UIKit
import Combine

final class PhotosListViewModel {
    @Injected private var dataService: (any DataServiceProtocol)?
    
    private var photos: [any PhotoProtocol] = []
    var photosCount: Int { photos.count }
    var photosUpdatesPublisher = PassthroughSubject<(indexes: [Int]?, count: Int?, removedIndex: Int?), Never>()
    
    let dataSource: DataSource
    
    private var awaitingForContent: Bool = false
    private var nothingToFetch: Bool = false
    private var targetElementsCount = Constants.photosFetchPageSize
    
    private var cancellable: AnyCancellable?
    
    // MARK: - Initialization
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - Public
    
    func startMonitor() {
        addPhotosUpdateSubscription()
        fetchMoreContentIfNeeded()
    }
    
    func fetchMoreContentIfNeeded(for itemIndex: Int? = nil) {
        if let itemIndex {
            targetElementsCount = max(targetElementsCount, itemIndex + Constants.imageFetchThreshold)
        }
        guard !nothingToFetch,
              !awaitingForContent,
              photos.count < targetElementsCount else { return }
        fetchMoreContent()
    }
    
    func photo(for index: Int) -> (any PhotoProtocol)? {
        fetchMoreContentIfNeeded(for: index)
        guard index < photos.count else { return nil }
        return photos[index]
    }
    
    func getImage(for index: Int, with size: CGSize) async -> (any ImageBoxProtocol)? {
        guard index < photos.count else { return nil }
        guard let image = await dataService?.scaledImage(for: photos[index], with: size) else { return nil }
        return image
    }
    
    func downloadImage(for index: Int) {
        guard index < photos.count else { return }
        let photo = photos[index]
        Task {
            guard let imageBox = await dataService?.downloadImage(for: photo),
                  let image = imageBox.image as? UIImage else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    func updatePhoto(for index: Int) async {
        guard index < photos.count else { return }
        let photo = photos[index]
        await dataService?.updatePhoto(photo: photo)
    }
    
    func toggleFavorite(for index: Int) {
        guard index < photos.count else { return }
        let photo = self.photos[index]
        Task { [weak dataService] in
            await dataService?.changePersistenceStatus(for: photo, to: !photo.isPersistent)
        }
    }
    
    // MARK: - Private
    private func addPhotosUpdateSubscription() {
        Task {
            cancellable = await dataService?.photosUpdatePublisher
                .sink { [weak self] in
                    self?.replacePhoto(photo: $0)
                }
        }
    }
    
    private func replacePhoto(photo: any PhotoProtocol) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            foundIndex(index)
        } else if dataSource == .favorite {
            photos.insert(photo, at: 0)
            photosUpdatesPublisher.send((indexes: [0], count: photos.count, removedIndex: nil))
        }
        
        func foundIndex(_ index: Int) {
            switch dataSource {
            case .all:
                photos[index] = photo
                photosUpdatesPublisher.send((indexes: [index], count: nil, removedIndex: nil))
            case .favorite:
                if photo.isPersistent {
                    photos[index] = photo
                    photosUpdatesPublisher.send((indexes: [index], count: nil, removedIndex: nil))
                } else {
                    photos.remove(at: index)
                    photosUpdatesPublisher.send((indexes: nil, count: photos.count, removedIndex: index))
                }
            }
        }
    }
    
    private func fetchMoreContent() {
        Task { [weak self] in
            defer { self?.awaitingForContent = false }
            
            self?.awaitingForContent = true
            
            let fetchedPhotos: [any PhotoProtocol]?
            guard let dataSource = self?.dataSource else { return }
            switch dataSource {
            case .all:
                fetchedPhotos = await self?.dataService?.getPhotos(for: nil)
            case .favorite:
                guard let fetchedFavoritePhotos = await self?.dataService?.getFavoritePhotos() else {
                    self?.nothingToFetch = true
                    return
                }
                fetchedPhotos = fetchedFavoritePhotos
            }
            
            guard let fetchedPhotos else { return }
            self?.photos.append(contentsOf: fetchedPhotos)
            self?.photosUpdatesPublisher.send((indexes: nil, count: self?.photos.count, removedIndex: nil))
            
            self?.fetchMoreContentIfNeeded()
        }
    }
}
