//
//  InfoStackView.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

extension PhotoDetailViewController.View {
    final class InfoStackView: UIStackView {
        private let viewsLabel = LabeledIcon(icon: UIImage(resource: .views))
        private let downloadsLabel = LabeledIcon(icon: UIImage(resource: .download))
        private let likesLabel = LabeledIcon(icon: UIImage(resource: .like))
        
        // MARK: - Initialization
        convenience init() {
            self.init(frame: .zero)
            setupStackView()
        }
        
        // MARK: - Setup
        private func setupStackView() {
            axis = .horizontal
            distribution = .equalCentering
            spacing = Constants.UserInterface.horizontalSpacing
            
            addArrangedSubview(viewsLabel)
            addArrangedSubview(downloadsLabel)
            addArrangedSubview(likesLabel)
        }
        
        // MARK: - Public
        func update(views: Int?, downloads: Int?, likes: Int) {
            viewsLabel.text = views.map(String.init)
            downloadsLabel.text = downloads.map(String.init)
            likesLabel.text = String(likes)
        }
    }
}
