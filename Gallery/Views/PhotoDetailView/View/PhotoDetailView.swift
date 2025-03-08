//
//  PhotoDetailView.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

extension PhotoDetailViewController {
    final class View: UIView {
        private let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            return scrollView
        }()
        
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = Constants.UserInterface.verticalSpacing
            stackView.layoutMargins = UIEdgeInsets(top: 0,
                                                   left: Constants.UserInterface.horizontalSpacing,
                                                   bottom: 0,
                                                   right: Constants.UserInterface.horizontalSpacing)
            stackView.isLayoutMarginsRelativeArrangement = true
            return stackView
        }()
        
        private let actionsStackView = TopStackView()
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = Constants.UserInterface.cornerRadius
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        private let infoStackView = InfoStackView()
        private let titleLabel: UILabel = UILabel(font: .preferredFont(forTextStyle: .subheadline))
        private let descriptionLabel: UILabel = {
            let label = UILabel(font: .preferredFont(forTextStyle: .subheadline).withWeight(.light))
            return label
        }()
        
        private var imageViewHeightConstraint: NSLayoutConstraint?
        
        // MARK: - Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
            makeConstraints()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
            makeConstraints()
        }
        
        // MARK: - Setup
        private func setup() {
            backgroundColor = .systemBackground
            
            addSubview(scrollView)
            scrollView.addSubview(stackView)
            stackView.addArrangedSubviews(imageView, actionsStackView, infoStackView, titleLabel, descriptionLabel)
        }
        
        // MARK: - Layout
        private func makeConstraints() {
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            // ScrollView
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            
            // StackView
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
        }
        
        // MARK: - Public
        func update(with photo: any PhotoProtocol) {
            updateImageView(with: photo)
            
            actionsStackView.update(creationDate: photo.publicationDate, isFavorite: photo.isPersistent)
            infoStackView.update(views: photo.views, downloads: photo.downloads, likes: photo.likes)
            titleLabel.text = photo.alternativeDescriptionText
            descriptionLabel.text = photo.descriptionText
        }
        
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
