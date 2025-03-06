//
//  PhotosListViewModel.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import UIKit
import Combine

final class PhotosListViewModel {
    @Injected var dataService: (any DataServiceProtocol)?
    
    @Published var photos: [any PhotoProtocol] = []
    var awaitingMoreContent: Bool = false
    
    // MARK: - Initialization
    init() {
        requestMoreContent()
    }
    
    // MARK: - Public
    func shouldRequestMoreContent(for itemIndex: Int) {
        guard !awaitingMoreContent,
              photos.count - itemIndex < Constants.imageFetchThreshold else { return }
        requestMoreContent()
    }
    
    func toggleFavorite(for itemIndex: Int) {
        photos[itemIndex].isFavorite.toggle()
    }
    func downloadImage(for itemIndex: Int) {
        
    }
    
    func getUpdatedPhoto(for id: String) async -> (any PhotoProtocol)? {
        guard var photo = await dataService?.getPhoto(for: id),
              let index = photos.firstIndex(where: { $0.id == id }) else { return nil }
        photo.isFavorite = photos[index].isFavorite
        photos[index] = photo
        return photo
    }
    func getImage(for requirements: any ImageRequirementsProtocol) async -> (any ImageBoxProtocol)? {
        guard let image = await dataService?.scaledImage(for: requirements) else { return nil }
        return image
    }
    
    // MARK: - Private
    private func requestMoreContent() {
        awaitingMoreContent = true
        
        Task { [weak self] in
            guard let dataService = self?.dataService,
                  let photos = await dataService.getPhotos(for: nil) else {
                self?.awaitingMoreContent = false
                return
            }
            
            self?.photos.append(contentsOf: photos)
            self?.awaitingMoreContent = false
        }
    }
    
}
