//
//  AlertServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 02.03.2025.
//

import UIKit

protocol AlertServiceProtocol {
    func showAlert(_ alert: Alert, on viewController: UIViewController)
    func showAlert(for error: any Error, on viewController: UIViewController)
}
