//
//  KeychainService.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation
import Security

final class KeychainService: KeychainServiceProtocol {
    private let keychainQuery: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrService: Bundle.main.bundleIdentifier!,
        kSecAttrAccount: "unsplashAPIKey"
    ]
    
    private lazy var _apiKey = getKey()
    var apiKey: String? {
        get { _apiKey }
        set {
            _apiKey = newValue
            try? setKey(newValue)
        }
    }
}

extension KeychainService {
    private func getKey() -> String? {
        var query = keychainQuery
        query[kSecReturnData] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            let alertService: (any AlertServiceProtocol)? = ServiceLocator.shared.resolve()
            Task { @MainActor in
                alertService?.showAlert(for: KeychainServiceError(status: status))
            }
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    private func setKey(_ key: String?) throws(KeychainServiceError) {
        guard let key = key else {
            try? deleteKey()
            return
        }
        
        let data = key.data(using: .utf8)!
        var query = keychainQuery
        query[kSecValueData] = data
        
        try? deleteKey()
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainServiceError(status: status) }
    }
    
    private func deleteKey() throws(KeychainServiceError) {
        let query = keychainQuery
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw KeychainServiceError(status: status) }
    }
}
