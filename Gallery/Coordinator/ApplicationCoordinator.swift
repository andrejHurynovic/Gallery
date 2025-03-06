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
    
    var isAPIKeyProvided: Bool {
        @Injected var alertService: (any KeychainServiceProtocol)?
        return alertService?.apiKey != nil
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
        let viewController = PhotosListViewController()
        navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - ApplicationNavigator
extension ApplicationCoordinator: ApplicationNavigator {
    func navigateToSettings() {
        
    }
}
