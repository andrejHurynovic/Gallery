//
//  UIApplication+topViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 04.03.2025.
//

import UIKit

extension UIApplication {
    @MainActor class func topViewController(of baseViewController: UIViewController? = nil) -> UIViewController? {
        let baseViewController = baseViewController ?? UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .filter({ $0.isKeyWindow }).first?.rootViewController
        
        if let navigationController = baseViewController as? UINavigationController {
            return topViewController(of: navigationController.visibleViewController)
        }
        if let tabBarController = baseViewController as? UITabBarController, let selected = tabBarController.selectedViewController {
            return topViewController(of: selected)
        }
        if let presentedViewController = baseViewController?.presentedViewController {
            return topViewController(of: presentedViewController)
        }
        
        return baseViewController
    }
}
