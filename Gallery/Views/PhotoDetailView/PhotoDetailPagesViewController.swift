//
//  PhotoDetailPagesViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 08.03.2025.
//

import UIKit

final class PhotoDetailPagesViewController: ReusablePagesViewController<PhotoDetailViewController> {
    var viewModel: PhotosListViewModel
    override var dataCount: Int { viewModel.photosCount }
    
    // MARK: - Initialization
    init(initialIndex: Int, viewModel: PhotosListViewModel) {
        self.viewModel = viewModel
        super.init(initialIndex: initialIndex)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))]
    }
    
    // MARK: - Public
    override func createReusableViewController() -> PhotoDetailViewController {
        PhotoDetailViewController(viewModel: viewModel)
    }
    
    // MARK: - Private
    @objc private func close() {
        dismiss(animated: true)
    }
}
