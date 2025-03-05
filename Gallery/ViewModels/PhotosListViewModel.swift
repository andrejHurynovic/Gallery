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
        guard awaitingMoreContent == false,
              photos.count - itemIndex < Constants.imageFetchThreshold else { return }
        requestMoreContent()
    }
    
    // MARK: - Private
    
    private func requestMoreContent() {
        awaitingMoreContent = true
        
        Task { [weak self] in
            guard let dataService = self?.dataService,
                  let photos = await dataService.getPhotos(for: "minsk") else {
                self?.awaitingMoreContent = false
                return
            }
            
            self?.photos.append(contentsOf: photos)
            self?.awaitingMoreContent = false
        }
    }
    
}
