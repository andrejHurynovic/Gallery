//
//  PostsMultiPageViewModel.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 11.03.2025.
//

final class PostsMultiPageViewModel {
    private var applicationNavigator: ApplicationNavigator
    
    // MARK: - Init
    init(applicationNavigator: ApplicationNavigator) {
        self.applicationNavigator = applicationNavigator
    }
    
    func navigateToSettings() {
        applicationNavigator.navigateToSettings()
    }
}
