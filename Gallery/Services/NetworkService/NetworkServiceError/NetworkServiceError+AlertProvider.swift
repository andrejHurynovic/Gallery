//
//  NetworkServiceError+AlertProvider.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 04.03.2025.
//

extension NetworkServiceError: AlertProvider {
    var alert: Alert? {
        switch self {
        case .incorrectAPIKey:
            return Alert(title: "Incorrect API Key",
                         message: "The API key you entered is incorrect. Please double-check the key and try again.",
                         actions: changeAPIKeyAction)
        case .rateLimitExceeded:
            return Alert(title: "Rate Limit Exceeded",
                         message: "The rate limit has been exceeded. Please wait a while before making more requests, or replace your API key.",
                         actions: changeAPIKeyAction)
        }
    }
    
    private var changeAPIKeyAction: Alert.Action {
        Alert.Action(text: "Change the key") {
            let applicationCoordinator: ApplicationCoordinator? = ServiceLocator.shared.resolve()
            applicationCoordinator?.navigateToSettings()
        }
    }
}
