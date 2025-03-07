//
//  PhotoDetailView.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

extension PhotoDetailViewController {
    final class View: UIView {
        private let scrollView = UIScrollView()
        private let stackView = UIStackView()
        
        private let actionsStackView = TopStackView()
        private let imageView = UIImageView()
        private let infoStackView = InfoStackView()
        private let titleLabel = UILabel(font: .preferredFont(forTextStyle: .subheadline))
        private let descriptionLabel = UILabel(font: .preferredFont(forTextStyle: .subheadline).withWeight(.light))
        
        private var imageViewHeightConstraint: NSLayoutConstraint?
        
        // MARK: - Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        // MARK: - Setup
        private func setup() {
            backgroundColor = .systemBackground
            
            setupScrollView()
            setupStackView()
            setupImageView()
            addStackViewElements()
        }
        
        private func setupScrollView() {
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(scrollView)
            
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
        
        private func setupStackView() {
            stackView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
            
            stackView.axis = .vertical
            stackView.spacing = Constants.UserInterface.verticalSpacing
            stackView.layoutMargins = UIEdgeInsets(top: Constants.UserInterface.verticalSpacing,
                                                   left: Constants.UserInterface.horizontalSpacing,
                                                   bottom: Constants.UserInterface.verticalSpacing,
                                                   right: Constants.UserInterface.horizontalSpacing)
            stackView.isLayoutMarginsRelativeArrangement = true
        }
        
        private func setupImageView() {
            imageView.layer.cornerRadius = Constants.UserInterface.cornerRadius
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
        }
        
        private func addStackViewElements() {
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(actionsStackView)
            stackView.addArrangedSubview(infoStackView)
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(descriptionLabel)
        }
        
        // MARK: - Public
        func updateImage(image: UIImage?) {
            guard let image = image else {
                imageView.image = nil
                return
            }
            UIView.transition(with: self, duration: Constants.animationDuration,
                              options: .transitionCrossDissolve) {
                self.imageView.image = image
            }
        }
        
        func update(with photo: any PhotoProtocol) {
            updateImageView(with: photo)
            
            actionsStackView.update(creationDate: photo.publicationDate, isFavorite: photo.isFavorite)
            infoStackView.update(views: photo.views, downloads: photo.downloads, likes: photo.likes)
            titleLabel.text = photo.alternativeDescriptionText
            descriptionLabel.text = photo.descriptionText
        }
        
        func updateActions(favoriteButtonAction: @escaping () -> Void,
                           downloadButtonAction: @escaping () -> Void) {
            actionsStackView.updateActions(favoriteButtonAction: favoriteButtonAction,
                                           downloadButtonAction: downloadButtonAction)
        }
        
        func imageViewWidth() -> CGFloat {
            return imageView.bounds.width
        }
        
        // MARK: - Private
        private func updateImageView(with photo: any PhotoProtocol) {
            let aspectRatio = CGFloat(photo.width) / CGFloat(photo.height)
            imageViewHeightConstraint?.isActive = false
            imageViewHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1 / aspectRatio)
            imageViewHeightConstraint?.isActive = true
            imageView.backgroundColor = UIColor(hexadecimalColorCode: photo.hexadecimalColorCode)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotoDetailViewController(viewModel: PhotosListViewModel(dataSource: .all))
}

@available(iOS 17.0, *)
#Preview {
    PhotoDetailViewController(viewModel: PhotosListViewModel(dataSource: .favorite))
}
