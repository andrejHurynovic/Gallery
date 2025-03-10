//
//  SettingsCoordinator.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

import UIKit

final class SettingsCoordinator: Coordinator {
    var parentCoordinator: (any Coordinator)?
    var children: [any Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Initialization
    init(parentCoordinator: (any Coordinator)? = nil, navigationController: UINavigationController) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = SettingsViewController(viewModel: SettingsViewModel(navigator: self))
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.tintColor = .label
        Task { @MainActor in
            UIApplication.topViewController()?.present(navigationController, animated: true)
        }
        self.navigationController = navigationController
    }
    func pop() {
        navigationController.popViewController(animated: true)
    }
}

extension SettingsCoordinator: SettingsNavigator {
    func navigateToSettingDetail(for setting: Setting, with initialText: String? = nil, action: @escaping (String) -> Void) {
        let viewController = TextSettingViewController(for: setting, with: initialText, action: action)
        navigationController.pushViewController(viewController, animated: true)
    }
    func navigateToAPIKeySetting(completion: (() -> Void)?) {
        let keychainService: (any KeychainServiceProtocol)? = ServiceLocator.shared.resolve()
        navigateToSettingDetail(for: .apiKey, with: keychainService?.apiKey) {
            keychainService?.apiKey = $0
            completion?()
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    let navigationController = UINavigationController()
    let coordinator = SettingsCoordinator(navigationController: navigationController)
    coordinator.start()
    return navigationController
}

@available(iOS 17.0, *)
#Preview {
    let navigationController = UINavigationController()
    let coordinator = SettingsCoordinator(navigationController: navigationController)
    coordinator.start()
    return navigationController
}
