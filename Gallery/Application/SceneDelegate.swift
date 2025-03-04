//
//  SceneDelegate.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var applicationCoordinator: ApplicationCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let navigationController = UINavigationController()
        let applicationCoordinator = ApplicationCoordinator(with: navigationController)
        ServiceLocator.shared.register(applicationCoordinator as ApplicationNavigator)
        applicationCoordinator.start()
        
        self.applicationCoordinator = applicationCoordinator
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
