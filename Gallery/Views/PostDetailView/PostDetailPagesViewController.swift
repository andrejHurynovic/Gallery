//
//  PostDetailPagesViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 08.03.2025.
//

import UIKit

final class PostDetailPagesViewController: ReusablePagesViewController<PostDetailViewController> {
    var viewModel: PostsListViewModel
    override var dataCount: Int { viewModel.postsCount }
    
    // MARK: - Initialization
    init(initialIndex: Int, viewModel: PostsListViewModel) {
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
    override func createReusableViewController() -> PostDetailViewController {
        PostDetailViewController(viewModel: viewModel)
    }
    
    // MARK: - Private
    @objc private func close() {
        dismiss(animated: true)
    }
}
