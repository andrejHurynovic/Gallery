//
//  TopStackView.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

extension PhotoDetailViewController.View {
    final class TopStackView: UIStackView {
        private let creationDateLabel = UILabel(font: UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 14)),
                                                color: .secondaryLabel)
        private let downloadButton = ImageButton(image: UIImage(resource: .download))
        private let favoriteButton = FavoriteButton()
        
        private let size: CGFloat = 48
        
        // MARK: - Initialization
        convenience init() {
            self.init(frame: .zero)
            setupStackView()
        }
        
        // MARK: - Setup
        private func setupStackView() {
            axis = .horizontal
            distribution = .fill
            creationDateLabel.setContentHuggingPriority(.required, for: .horizontal)
            spacing = Constants.UserInterface.horizontalSpacing
            
            addArrangedSubview(RoundedContainerView(content: creationDateLabel))
            let downloadButtonContainer = RoundedContainerView(content: downloadButton, isFilled: true)
            let favoriteButtonContainer = RoundedContainerView(content: favoriteButton, isFilled: true)
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: size),
                downloadButtonContainer.widthAnchor.constraint(equalToConstant: size),
                favoriteButtonContainer.widthAnchor.constraint(equalToConstant: size)
            ])
            addArrangedSubview(downloadButtonContainer)
            addArrangedSubview(favoriteButtonContainer)
        }
        
        // MARK: - Public
        func update(creationDate: Date, isFavorite: Bool) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            creationDateLabel.text = "Published " + dateFormatter.string(from: creationDate)
            
            favoriteButton.isFavorite = isFavorite
        }
        
        func updateActions(favoriteButtonAction: @escaping () -> Void,
                           downloadButtonAction: @escaping () -> Void) {
            favoriteButton.action = favoriteButtonAction
            downloadButton.action = downloadButtonAction
        }
    }
}
