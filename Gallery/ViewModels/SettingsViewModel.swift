//
//  SettingsViewModel.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 10.03.2025.
//

import Foundation

final class SettingsViewModel {
    private var navigator: any SettingsNavigator
    
    // MARK: - Initialization
    init(navigator: any SettingsNavigator) {
        self.navigator = navigator
    }
    
    // MARK: - Public
    func performAction(for setting: Setting) {
        switch setting {
        case .apiKey: apiKeyAction()
        case .cacheCount: cacheCountAction()
        case .clearDatabase: clearDatabaseAction()
        }
    }
}

// MARK: - Actions
private extension SettingsViewModel {
    func apiKeyAction() {
        @Injected var keychainService: (any KeychainServiceProtocol)?
        navigator.navigateToSettingDetail(for: .apiKey, with: keychainService?.apiKey) {
            keychainService?.apiKey = $0
            self.navigator.pop()
        }
    }
    func cacheCountAction() {
        @Injected var alertService: (any AlertServiceProtocol)?
        @Injected var imageCacheService: (any ImageCacheServiceProtocol)?
        var initialText: String?
        if let countLimit = imageCacheService?.countLimit {
            initialText = String(countLimit)
        }
        
        navigator.navigateToSettingDetail(for: .cacheCount, with: initialText) {
            if let cacheCount = Int($0), cacheCount > 0 {
                imageCacheService?.countLimit = cacheCount
                UserDefaults.standard.set(cacheCount, forKey: Constants.UserDefaults.imageCacheServiceCountLimit)
                self.navigator.pop()
            } else {
                Task { await alertService?.showAlert(Alert(title: "Incorrect value")) }
            }
        }
    }
    func clearDatabaseAction() {
        @Injected var alertService: (any AlertServiceProtocol)?
        @Injected var databaseService: (any DatabaseServiceProtocol)?
        let action = Alert.Action(text: "Delete", style: .destructive) {
            Task { await databaseService?.deleteAll() }
        }
        let alert = Alert(title: "Warning",
                          message: "Are you sure you want to delete all data?",
                          actions: action,
                          defaultDismissAction: .chancel)
        Task { await alertService?.showAlert(alert) }
    }
}
