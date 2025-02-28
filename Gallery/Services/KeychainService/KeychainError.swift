//
//  KeychainError.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

enum KeychainError: Error {
    case itemAlreadyExist
    case itemNotFound
    case errorStatus(String?)
    
    init(status: OSStatus) {
        switch status {
        case errSecDuplicateItem:
            self = .itemAlreadyExist
        case errSecItemNotFound:
            self = .itemNotFound
        default:
            let message = SecCopyErrorMessageString(status, nil) as String?
            self = .errorStatus(message)
        }
    }
}
