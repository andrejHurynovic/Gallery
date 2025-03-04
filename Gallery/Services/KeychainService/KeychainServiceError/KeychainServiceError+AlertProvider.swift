//
//  KeychainServiceError+AlertProvider.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 04.03.2025.
//

extension KeychainServiceError: AlertProvider {
    var alert: Alert? {
        switch self {
        case .itemNotFound:
            return Alert(title: "API Key Not Found",
                         message: "The API key could not be found in the keychain.",
                         actions: setAPIKeyAction)
        default: return nil
        }
    }
    
    private var setAPIKeyAction: Alert.Action {
        Alert.Action(text: "Set the key") {
            let applicationCoordinator: ApplicationCoordinator? = ServiceLocator.shared.resolve()
            applicationCoordinator?.navigateToSettings()
        }
    }
}
