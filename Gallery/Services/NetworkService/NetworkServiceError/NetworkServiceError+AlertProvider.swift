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
                         actions: settingsAction)
        case .rateLimitExceeded:
            return Alert(title: "Rate Limit Exceeded",
                         message: "The rate limit has been exceeded. Please wait a while before making more requests, or replace your API key.",
                         actions: settingsAction)
        }
    }
    
    private var settingsAction: Alert.Action {
        Alert.Action(text: "Settings") {
            @Injected var applicationNavigator: (any ApplicationNavigator)?
            applicationNavigator?.navigateToSettings()
        }
    }
}
