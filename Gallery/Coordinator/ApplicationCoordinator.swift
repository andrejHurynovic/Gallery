//
//  ApplicationCoordinator.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import UIKit

final class ApplicationCoordinator: Coordinator {
    weak var parentCoordinator: (any Coordinator)?
    var children: [any Coordinator] = []
    let navigationController: UINavigationController
    
    private var isAPIKeyProvided: Bool {
        @Injected var keychainService: (any KeychainServiceProtocol)?
        return keychainService?.apiKey != nil
    }
    
    // MARK: - Initialization
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public
    func start() {
        if isAPIKeyProvided {
            navigateToPhotosListView()
        } else {
            navigateToPhotosListView()
        }
    }
    
    // MARK: - Private
    private func navigateToPhotosListView() {
        let allViewController = PhotosListViewController(viewModel: PhotosListViewModel(dataSource: .all))
        let favoriteViewController = PhotosListViewController(viewModel: PhotosListViewModel(dataSource: .favorite))
        let viewController = DualPageViewController(leadingViewController: allViewController,
                                                    trailingViewController: favoriteViewController,
                                                    leadingText: "All",
                                                    trailingText: "Favorite")
        navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - ApplicationNavigator
extension ApplicationCoordinator: ApplicationNavigator {
    func navigateToSettings() {
        
    }
}
