//
//  PhotosListViewModel+Alerts.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 11.03.2025.
//

import UIKit

extension PhotosListViewModel {
    func imageSaveConfirmationAlert(for post: any PhotoProtocol) -> Alert {
        Alert(title: "Save Photo",
              message: "Do you want to save this photo to your album?",
              actions: imageSaveAction(post: post),
              defaultDismissAction: .chancel)
    }
    
    private static var successfulImageSaveAlert: Alert {
        Alert(title: "Success",
              message: "The photo has been successfully saved to your album.")
    }
    
    private func imageSaveAction(post: any PhotoProtocol) -> Alert.Action {
        Alert.Action(text: "Save") {
            Task {
                @Injected var alertService: AlertServiceProtocol?
                @Injected var dataService: DataServiceProtocol?
                
                guard let imageBox = await dataService?.downloadImage(for: post),
                      let image = imageBox.image as? UIImage else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                await alertService?.showAlert(PhotosListViewModel.successfulImageSaveAlert)
            }
        }
    }
}
