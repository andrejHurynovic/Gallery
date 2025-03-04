//
//  AlertServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 02.03.2025.
//

import UIKit

protocol AlertServiceProtocol {
    @MainActor func showAlert(_ alert: Alert)
    @MainActor func showAlert(_ alert: Alert, on viewController: UIViewController)
    @MainActor func showAlert(for error: any Error)
    @MainActor func showAlert(for error: any Error, on viewController: UIViewController)
}
