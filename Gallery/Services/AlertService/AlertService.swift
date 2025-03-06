//
//  AlertService.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 02.03.2025.
//

import UIKit

final class AlertService: AlertServiceProtocol {
    private var lastShownAlert: Alert?
    private var lastShownTime: Date?
    
    private var alertQueue = [Alert]()
    private var isShowingAlert = false
    
    @MainActor func showAlert(_ alert: Alert) {
        guard let topViewController = UIApplication.topViewController() else { return }
        showAlert(alert, on: topViewController)
    }
    
    @MainActor func showAlert(_ alert: Alert, on viewController: UIViewController) {
        let currentTime = Date()
        
        guard lastShownAlert != alert || currentTime.timeIntervalSince(lastShownTime!) > Constants.alertCooldownTime else { return }
        
        lastShownAlert = alert
        lastShownTime = currentTime
        
        if isShowingAlert {
            alertQueue.append(alert)
        } else {
            presentAlert(alert, on: viewController)
        }
    }
    
    @MainActor func showAlert(for error: any Error) {
        guard let topViewController = UIApplication.topViewController() else { return }
        showAlert(for: error, on: topViewController)
    }
    
    @MainActor func showAlert(for error: Error, on viewController: UIViewController) {
        let alert: Alert
        switch error {
        case let error as AlertProvider:
            guard let providedAlert = error.alert else { fallthrough }
            alert = providedAlert
        default:
            alert = Alert(title: "An error occurred", message: error.localizedDescription)
        }
        showAlert(alert, on: viewController)
    }
}

extension AlertService {
    private func presentAlert(_ alert: Alert, on viewController: UIViewController) {
        isShowingAlert = true
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        
        let actions = alert.actions.map { [weak self, weak viewController] action in
            UIAlertAction(title: action.text, style: action.style) { _ in
                action.action?()
                viewController?.dismiss(animated: true) {
                    self?.isShowingAlert = false
                    self?.showNextAlertIfNeeded(on: viewController)
                }
            }
        }
        actions.forEach { alertController.addAction($0) }
        
        viewController.present(alertController, animated: true)
    }
    
    private func showNextAlertIfNeeded(on viewController: UIViewController?) {
        guard let viewController = viewController, !alertQueue.isEmpty else { return }
        let nextAlert = alertQueue.removeFirst()
        presentAlert(nextAlert, on: viewController)
    }
}
