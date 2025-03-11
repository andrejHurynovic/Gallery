//
//  PostsListViewModel+Alerts.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 11.03.2025.
//

import UIKit

extension PostsListViewModel {
    func imageSaveConfirmationAlert(for post: any PostProtocol) -> Alert {
        Alert(title: "Save Post",
              message: "Do you want to save this post to your album?",
              actions: imageSaveAction(post: post),
              defaultDismissAction: .chancel)
    }
    
    private static var successfulImageSaveAlert: Alert {
        Alert(title: "Success",
              message: "The post has been successfully saved to your album.")
    }
    
    private func imageSaveAction(post: any PostProtocol) -> Alert.Action {
        Alert.Action(text: "Save") {
            Task {
                @Injected var alertService: AlertServiceProtocol?
                @Injected var dataService: DataServiceProtocol?
                
                guard let imageBox = await dataService?.downloadImage(for: post),
                      let image = imageBox.image as? UIImage else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                await alertService?.showAlert(PostsListViewModel.successfulImageSaveAlert)
            }
        }
    }
}
