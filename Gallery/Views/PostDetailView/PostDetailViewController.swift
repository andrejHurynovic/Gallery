//
//  PostDetailViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

final class PostDetailViewController: ReusablePageViewController {
    private let viewModel: PostsListViewModel
    
    private var lastImageViewWidth: CGFloat = 0.0
    private var contentView = View()
    
    private var imageUpdateTask: Task<Void, Never>?
    private var postUpdateTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(viewModel: PostsListViewModel) {
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
        updateImage()
    }
    
    // MARK: - Public
    override func update(index: Int) {
        prepareForReuse()
        super.update(index: index)
        self.index = index
        
        contentView.updateImage(image: nil)
        updatePost()
        
        guard let post = viewModel.post(for: index) else { return }
        
        updateImage(post: post)
        contentView.update(with: post)
        
        setupActions(for: index)
    }
    
    // MARK: - Private
    private func setupActions(for index: Int) {
        let favoriteButtonAction: () -> Void = { [weak self] in self?.viewModel.toggleFavorite(for: index) }
        let downloadButtonAction: () -> Void = { [weak self] in self?.viewModel.downloadImage(for: index) }
        contentView.updateActions(favoriteButtonAction: favoriteButtonAction,
                                  downloadButtonAction: downloadButtonAction)
    }
    private func prepareForReuse() {
        lastImageViewWidth = 0.0
        imageUpdateTask?.cancel()
        postUpdateTask?.cancel()
    }
}

private extension PostDetailViewController {
    func updatePost() {
        let index = index!
        postUpdateTask = Task { [weak self] in
            await self?.viewModel.updatePost(for: index)
            guard Task.isCancelled == false,
            let post = self?.viewModel.post(for: index) else { return }
            await MainActor.run {
                self?.contentView.update(with: post)
            }
        }
    }
    
    func updateImage(post: (any PostProtocol)? = nil) {
        let index = index!
        
        let currentImageViewWidth = contentView.imageViewWidth()
        guard currentImageViewWidth != 0,
              lastImageViewWidth < currentImageViewWidth else { return }
        lastImageViewWidth = currentImageViewWidth
        
        imageUpdateTask = Task { [weak self] in
            guard let imageBox = await self?.viewModel.getImage(for: index, with: CGSize(width: currentImageViewWidth, height: 0)),
                  Task.isCancelled == false,
                  let image = imageBox.image as? UIImage else { return }
            await MainActor.run {
                self?.contentView.updateImage(image: image)
            }
        }
    }
}
