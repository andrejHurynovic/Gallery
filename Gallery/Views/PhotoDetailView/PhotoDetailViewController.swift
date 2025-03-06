//
//  PhotoDetailViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

final class PhotoDetailViewController: UIViewController {
    private let viewModel: PhotosListViewModel
    
    private var imageUpdateTask: Task<Void, Never>?
    private var photoUpdateTask: Task<Void, Never>?
    
    private var photo: (any PhotoProtocol)!
    
    private var contentView = View()
    
    private var lastImageViewWidth: CGFloat = 0.0
    
    // MARK: - Initialization
    init(viewModel: PhotosListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateImage(with: photo)
    }
    
    // MARK: - Public
    func update(with photo: any PhotoProtocol, index: Int) {
        contentView.updateImage(image: nil)
        imageUpdateTask?.cancel()
        photoUpdateTask?.cancel()
        
        updatePhoto(with: photo)
        updateImage(with: photo)
        
        self.photo = photo
        contentView.update(with: photo)
        
        setupActions(for: index)
    }
    
    // MARK: - Private
    private func setupActions(for index: Int) {
        let favoriteButtonAction: () -> Void = { [weak self] in self?.viewModel.toggleFavorite(for: index) }
        let downloadButtonAction: () -> Void = { [weak self] in self?.viewModel.downloadImage(for: index) }
        contentView.updateActions(favoriteButtonAction: favoriteButtonAction,
                                  downloadButtonAction: downloadButtonAction)
    }
}

private extension PhotoDetailViewController {
    func updatePhoto(with photo: any PhotoProtocol) {
        let identifier = photo.id
        photoUpdateTask = Task { [weak self] in
            guard let photo = await self?.viewModel.getUpdatedPhoto(for: identifier),
                  Task.isCancelled == false else { return }
            await MainActor.run {
                self?.contentView.update(with: photo)
            }
        }
    }
    
    func updateImage(with photo: any PhotoProtocol) {
        let currentImageViewWidth = contentView.imageViewWidth()
        guard currentImageViewWidth != 0,
              lastImageViewWidth < currentImageViewWidth else { return }
        lastImageViewWidth = currentImageViewWidth
        
        let requirements = ImageRequirements(id: photo.id,
                                             imageURL: photo.imageURL,
                                             requiredWidth: currentImageViewWidth,
                                             requiredHeight: 0)
        imageUpdateTask = Task { [weak self] in
            guard let imageBox = await self?.viewModel.getImage(for: requirements),
                  Task.isCancelled == false,
                  let image = imageBox.image as? UIImage else { return }
            await MainActor.run {
                self?.contentView.updateImage(image: image)
            }
        }
    }
}
