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
            Alert(title: "Incorrect API Key",
                  message: "The API key you entered is incorrect. Please double-check the key and try again.",
                  actions: settingsAction)
        case .rateLimitExceeded:
            Alert(title: "Rate Limit Exceeded",
                  message: "The rate limit has been exceeded. Please wait a while before making more requests, or replace your API key.",
                  actions: settingsAction)
        case .noConnection:
            Alert(title: "No Connection",
                  message: "There is no internet connection. Please check your network settings and try again.")
        }
    }
    
    private var settingsAction: Alert.Action {
        Alert.Action(text: "Settings") {
            @Injected var applicationNavigator: (any ApplicationNavigator)?
            applicationNavigator?.navigateToSettings()
        }
    }
}
