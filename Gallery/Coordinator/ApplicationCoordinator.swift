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
    
    var settingsCoordinator: SettingsCoordinator {
        SettingsCoordinator(parentCoordinator: self, navigationController: navigationController)
    }
    
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
            navigateToPhotosMultiPage()
        } else {
            settingsCoordinator.navigateToAPIKeySetting {
                self.navigateToPhotosMultiPage()
                guard let dualPagePhotosViewController = self.navigationController.viewControllers.last else { return }
                self.navigationController.setViewControllers([dualPagePhotosViewController], animated: true)
            }
        }
    }
}

// MARK: - ApplicationNavigator
extension ApplicationCoordinator: ApplicationNavigator {
    func navigateToPhotosMultiPage() {
        let viewController = PhotosMultiPageViewController(viewModel: PhotosMultiPageViewModel(applicationNavigator: self))
        navigationController.pushViewController(viewController, animated: true)
    }
    func navigateToSettings() {
        settingsCoordinator.start()
    }
}

@available(iOS 17.0, *)
#Preview {
    let navigationController = UINavigationController()
    let applicationCoordinator = ApplicationCoordinator(with: navigationController)
    applicationCoordinator.start()
    return navigationController
}
